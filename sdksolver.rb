#!/usr/bin/env ruby

DEBUG = false

def log(s)
  puts "#{s}" if DEBUG
end

ROWS = ('A'..'I').map(&:to_s)
COLS = (1..9).map(&:to_s)
VALUES = (1..9).map(&:to_s).join
ROW_NEIGHBORS = [ 'ABC', 'DEF', 'GHI']
COL_NEIGHBORS = [ '123', '456', '789']
GRID = ROWS.product(COLS)

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
    g2 = Marshal.load(Marshal.dump(g))
    log "Trying #{r}#{c} : #{v}"

    next if invalid?(g2, r, c, v)
    next if remove_v(g2, r, c, v).nil?

    log "Proceeding with value #{v} for #{r}#{c}"

    solution = solve(g2)
    next if solution.nil?

    return solution 
  end
  
  return nil
end

def invalid?(grid, row, col, value)
  grid[row][col] = value

  return false if value.length != 1
  return (
    row_neighbors(row, col).any? do |r, c|
      grid[r][c].eql?(value)
    end ||

    col_neighbors(row, col).any? do |r, c|
      grid[r][c].eql?(value)
    end
  )
end

def remove_v(grid, row, col, value)
  unit_neighbors(row, col)
    .reject { |s| s.eql?([row, col]) }
    .reject { |r, c| grid[r][c].length == 1 }
    .each { |r, c|
    return if invalid?(grid, r, c, grid[r][c].gsub(value, ''))
  }

  row_neighbors(row, col)
    .reject { |r, c| grid[r][c].length == 1 }
    .each { |r, c|
    return if invalid?(grid, r, c, grid[r][c].gsub(value, ''))
  }
  
  col_neighbors(row, col)
    .reject { |r, c| grid[r][c].length == 1 }
    .each { |r, c|
    return if invalid?(grid, r, c, grid[r][c].gsub(value, ''))
  }

  return true
end

def row_neighbors(r, c)
  COLS.map { |col| [r, col] }.reject { |u| unit_neighbors(r, c).include?(u) }
end

def col_neighbors(r, c)
  ROWS.map { |row| [row, c] }.reject { |u| unit_neighbors(r, c).include?(u) }
end

def unit_neighbors(r, c)
  ROW_NEIGHBORS.find { |s| s.include?(r) }.chars
    .product(COL_NEIGHBORS.find { |s| s.include?(c) }.chars)
end

def solved?(g)
  !g.find {|k, v| v.values.any?{|a| a.length != 1}}
end

def prepare(grid)
  ROW_NEIGHBORS.product(COL_NEIGHBORS).each { |urows, ucols|
    values_present = urows.chars.product(ucols.chars)
      .map { |r, c| grid[r][c] }
      .reject { |v| v == '.' }
      .join

    urows.chars.product(ucols.chars).each { |r, c| 
      grid[r][c] = VALUES.delete(values_present) if grid[r][c] == '.'
    }
  }

  return grid
end

def write(grid)
  grid.map { |k, v| v.values.join('|')}.join("\n")
end

def parse(file)
  return {} if file.nil?

  lines = File.read(file).split("\n")
  ROWS.zip(lines)
    .to_h
    .map { |k, v| [k, COLS.zip(v.chars).to_h] }.to_h
end

grid = parse(ARGV[0])
puts "Initial state:"
puts "#{write(grid)}"
puts "Solution: "
puts "#{write(solve(prepare(grid)))}"
#solve(prepare(grid))
