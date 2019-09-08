#!/usr/bin/env ruby

def log(s)
  puts "#{s}" if DEBUG
end

def solve(g)
  if(solved?(g))
    log "#{write(g).to_s}"
    return g
  end

  # pick an unsolved square
  # pick square with least values possible
  min_length = GRID.map { |(r, c)| g[r][c].length }.reject { |v| v == 1}.min
  r, c = GRID.find { |(r, c)| g[r][c].length == min_length }
  log "We choose #{r}#{c}"

  # pick a value for the square
  g[r][c].chars.each do |v|
    solution = process(g, r, c, v)
    return solution unless solution.nil?
  end
  
  return nil
end

def process(grid, row, col, value)
    g = Marshal.load(Marshal.dump(grid))
    log "Trying #{row}#{col} : #{value}"

    g[row][col] = value
    return if (
      invalid?(g, row, col) ||
      UN[[row, col]].any? { |r, c| invalid_remove?(g, r, c, value) }
    )

    log "Proceeding with value #{value} for #{row}#{col}"

    solve(g)
end

def invalid_remove?(g, r, c, value)
  return false if g[r][c].length == 1

  g[r][c] = g[r][c].delete(value)
  return invalid?(g, r, c)
end

def invalid?(grid, row, col)
  value = grid[row][col]

  value.length == 1 && (
    RN[row]
    .reject { |r, c| c.eql?(col) }
    .any? { |r, c| grid[r][c].eql?(value) || invalid_remove?(grid, r, c, value) } ||

  CN[col]
    .reject { |r, c| r.eql?(row) }
    .any? { |r, c| grid[r][c].eql?(value) || invalid_remove?(grid, r, c, value) }
  )
end

def solved?(g)
  !g.any? {|k, v| v.values.any?{|a| a.length != 1}}
end

def prepare(grid)
  UNITS.each { |urows, ucols|
    cells = urows.chars.product(ucols.chars)
    values = cells.map { |r, c| grid[r][c] }.join.delete('.')

    cells.each { |r, c| grid[r][c] = VALUES.delete(values) if grid[r][c] == '.' }
  }

  ROWS.each { |r|
    values = RN[r].map { |r, c| grid[r][c] if grid[r][c].length == 1 && grid[r][c] != '.' }.join

    RN[r].each { |r, c| grid[r][c].delete!(values) if grid[r][c].length != 1 }
  }

  # this breaks correctness but why? :(
  COLS.each { |c|
    values = CN[c].map { |r, c| grid[r][c] if grid[r][c].length == 1 && grid[r][c] != '.' }.join

    #CN[c].each { |r, c|  grid[r][c].delete!(values) if grid[r][c].length != 1  }
  }

  log "Prepared grid:"
  log "#{write(grid)}"

  grid
end

def write(grid)
  grid.map { |k, v| v.values.join('|')}.join("\n") unless grid.nil?
end

def parse(file)
  raise "No input file provided" if file.nil?

  lines = File.read(file).split("\n")
  ROWS.zip(lines)
    .to_h
    .map { |k, v| [k, COLS.zip(v.chars).to_h] }.to_h
end

ROWS = ('A'..'I').map(&:to_s)
COLS = (1..9).map(&:to_s)
GRID = ROWS.product(COLS)

VALUES = (1..9).map(&:to_s).join

UNITS = ['ABC', 'DEF', 'GHI'].product([ '123', '456', '789'])
UN = UNITS.map { |(r, c)|
  cells = r.chars.product(c.chars)
  cells.map { |cell| [cell, cells.reject { |s| s.eql?([r, c]) }] }
}.map(&:to_h).reduce(&:merge)

RN = ROWS.map { |r| [r, COLS.map { |c| [r, c] }] }.to_h
CN = COLS.map { |c| [c, ROWS.map { |r| [r, c] }] }.to_h

DEBUG = false

grid = parse(ARGV[0])
puts "Initial state:"
puts "#{write(grid)}"
puts "Solution: "
puts "#{write(solve(prepare(grid)))}"
