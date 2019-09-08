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
  min_length = g.values.map(&:values).map(&:flatten).flatten.reject{|v| v.length == 1}.map(&:length).min
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
    return if invalid?(g, row, col)

    return if UN[[row, col]]
      .reject { |s| s.eql?([row, col]) }
      .reject { |r, c| g[r][c].length == 1 }
      .any? { |r, c|
      g[r][c] = g[r][c].gsub(value, '')
      invalid?(g, r, c)
    }

    return if RN[[row, col]]
      .reject { |r, c| g[r][c].length == 1 }
      .any? { |r, c|
      g[r][c] = g[r][c].gsub(value, '')
      invalid?(g, r, c)
    }

    return if CN[[row, col]]
      .reject { |r, c| g[r][c].length == 1 }
      .any? { |r, c|
      g[r][c] = g[r][c].gsub(value, '')
      invalid?(g, r, c)
    }

    log "Proceeding with value #{value} for #{row}#{col}"

    solve(g)
end

def invalid?(grid, row, col)
  value = grid[row][col]

  return false if value.length != 1

  return (
    RN[[row, col]].any? { |r, c| grid[r][c].eql?(value) } ||
    CN[[row, col]].any? { |r, c| grid[r][c].eql?(value) }
  )
end

def row_neighbors(r, c)
  COLS.map { |col| [r, col] }.reject { |u| UN[[r, c]].include?(u) }
end

def col_neighbors(r, c)
  ROWS.map { |row| [row, c] }.reject { |u| UN[[r, c]].include?(u) }
end

def solved?(g)
  !g.find {|k, v| v.values.any?{|a| a.length != 1}}
end

def prepare(grid)
  UNITS.each { |urows, ucols|
    cells = urows.chars.product(ucols.chars)
    unit_values = cells.map { |r, c| grid[r][c] }.join.delete('.')
    possibilites = VALUES.delete(unit_values)

    cells
      .select {|r, c| grid[r][c] == '.' }
      .each { |r, c| grid[r][c] = possibilites }
  }

  grid
end

def write(grid)
  grid.map { |k, v| v.values.join('|')}.join("\n")
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

ROW_NEIGHBORS = [ 'ABC', 'DEF', 'GHI']
COL_NEIGHBORS = [ '123', '456', '789']
UNITS = ROW_NEIGHBORS.product(COL_NEIGHBORS)

UN = UNITS.map { |(r, c)|
  cells = r.chars.product(c.chars)
  cells.map { |cell| [cell, cells] }
}.map(&:to_h).reduce(&:merge)

RN = GRID.map { |(r, c)| [[r, c], row_neighbors(r, c)] }.to_h
CN = GRID.map { |(r, c)| [[r, c], col_neighbors(r, c)] }.to_h

DEBUG = false

grid = parse(ARGV[0])
puts "Initial state:"
puts "#{write(grid)}"
puts "Solution: "
puts "#{write(solve(prepare(grid)))}"
