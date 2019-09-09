#!/usr/bin/env crystal

alias Grid = Hash(Char, Hash(Char, String))

def log(s)
  puts "#{s}" if DEBUG
end

def solve(g : Grid): (Grid | Nil)
  if(solved?(g))
    log "#{write(g).to_s}"
    return g
  end

  # pick an unsolved square
  # pick square with least values possible
  min_length = GRID.map { |(r, c)| g[r][c].size }.reject { |v| v == 1}.min
  r, c = GRID.find([] of Char) { |r, c| g[r][c].size == min_length }
  log "We choose #{r}#{c}"

  # pick a value for the square
  g[r][c].chars.each do |v|
    solution = process(g, r, c, v.to_s)
    return solution unless solution.nil?
  end
end

# explore possibility of grid[row][col] = value
def process(grid : Grid, row : Char, col : Char, value : String) : (Grid | Nil)
    g = grid.clone
    log "Trying #{row}#{col} : #{value}"

    g[row][col] = value
    return if invalid?(g, row, col)

    log "Proceeding with value #{value} for #{row}#{col}"

    solve(g)
end

# Is setting grid[row][col] an invalid move?
def invalid?(grid : Grid, row : Char, col : Char): Bool
  value = grid[row][col]

  value.size == 1 && (
    UN[{row, col}].any? { |r, c| invalid_remove?(grid, r, c, value) } ||
    RN[row]
    .reject { |_, c| c == col }
    .any? { |r, c| grid[r][c] == value || invalid_remove?(grid, r, c, value) } ||

  CN[col]
    .reject { |r, _| r == row }
    .any? { |r, c| grid[r][c] == value || invalid_remove?(grid, r, c, value) }
  )
end

# Is removing 'v' from g[r][c] an invalid (re)move?
def invalid_remove?(g : Grid, r : Char, c : Char, v : String): Bool
  return false if g[r][c].size == 1

  g[r][c] = g[r][c].delete(v)
  return invalid?(g, r, c)
end

def solved?(g : Grid): Bool
  !g.any? {|k, v| v.values.any?{|a| a.size != 1}}
end

def prepare(grid : Grid): Grid
  UNITS.each { |urows, ucols|
    cells = urows.chars.product(ucols.chars)
    values = cells.map { |r, c| grid[r][c] }.join

    cells.each { |r, c| grid[r][c] = VALUES.delete(values) if grid[r][c] == "." }
  }

  ROWS.each { |r|
    values = RN[r].map { |r, c| grid[r][c] if grid[r][c].size == 1 }.join

    RN[r].each { |r, c| grid[r][c] = grid[r][c].delete(values) if grid[r][c].size != 1 }
  }

  COLS.each { |c|
    values = CN[c].map { |r, c| grid[r][c] if grid[r][c].size == 1}.join

    CN[c].each { |r, c|  grid[r][c] = grid[r][c].delete(values) if grid[r][c].size != 1  }
  }

  log "Prepared grid:"
  log "#{write(grid)}"

  grid
end

def write(grid : Grid | Nil)
  grid.map { |k, v| v.values.join('|')}.join("\n") unless grid.nil?
end

def parse(file : String): Grid
  raise "No input file provided" if file.nil?

  lines = File.read(file).split('\n').map(&.chars)

  ROWS.zip(lines).to_h
    .transform_values { |v|
    COLS.zip(v).to_h
      .transform_values(&.to_s) }
end

ROWS = ('A'..'I').to_a
COLS = ('1'..'9').to_a
GRID = ROWS.product(COLS)

VALUES = ('1'..'9').join

UNITS = ["ABC", "DEF", "GHI"].product([ "123", "456", "789"])
UN = UNITS.map { |(r, c)|
  cells = r.chars.product(c.chars)

  cells.map { |cell| {cell, cells.reject { |s| s == {r, c} }} }
}.map(&.to_h).reduce { |h, n| h.merge(n) }

RN = ROWS.map { |r| {r, COLS.map { |c| {r, c} }} }.to_h
CN = COLS.map { |c| {c, ROWS.map { |r| {r, c} }} }.to_h

DEBUG = false

grid = parse(ARGV[0])
puts "Initial state:"
puts "#{write(grid)}"
puts "Solution: "
puts "#{write(solve(prepare(grid)))}"
