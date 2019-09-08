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
    return if invalid?(g, row, col)

    return if UN[[row, col]]
      .reject { |r, c| g[r][c].length == 1 }
      .any? { |r, c|
      g[r][c] = g[r][c].gsub(value, '')
      invalid?(g, r, c)
    }

    return if RN[row]
      .reject { |s| s.eql?([row, col]) }
      .reject { |r, c| g[r][c].length == 1 }
      .any? { |r, c|
      g[r][c] = g[r][c].gsub(value, '')
      invalid?(g, r, c)
    }

    return if CN[col]
      .reject { |s| s.eql?([row, col]) }
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
    RN[row]
    .any? { |r, c| c != col && grid[r][c].eql?(value) } ||

    CN[col]
    .any? { |r, c| r != row && grid[r][c].eql?(value) }
  )
end

def solved?(g)
  !g.any? {|k, v| v.values.any?{|a| a.length != 1}}
end

def prepare(grid)
  UNITS.each { |urows, ucols|
    cells = urows.chars.product(ucols.chars)
    unit_values = cells.map { |r, c| grid[r][c] }.join.delete('.')
    possibilites = VALUES.delete(unit_values)

    cells.each { |r, c| grid[r][c] = possibilites if grid[r][c] == '.' }
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

UNITS = ['ABC', 'DEF', 'GHI'].product([ '123', '456', '789'])
UN = UNITS.map { |(r, c)|
  cells = r.chars.product(c.chars)
  cells.map { |cell| [cell, cells.reject { |s| s.eql?(cell) }] }
}.map(&:to_h).reduce(&:merge)

RN = ROWS.map { |r| [r, COLS.map { |c| [r, c] }] }.to_h
CN = COLS.map { |c| [c, ROWS.map { |r| [r, c] }] }.to_h

DEBUG = false

grid = parse(ARGV[0])
puts "Initial state:"
puts "#{write(grid)}"
puts "Solution: "
puts "#{write(solve(prepare(grid)))}"
