#!/usr/bin/env ruby

require 'json'

ROWS = [ 'ABC', 'DEF', 'GHI' ]
COLS = [ 'ADG', 'BEH', 'CFI' ]

def solve(grid)
  g = Marshal.load(Marshal.dump(grid))
  if(solved?(g))
    puts 'solved'
    puts "#{g}"
    return g
  end

  # pick an unsolved square
  # pick square with least values possible
  min_length = g.values.map(&:values).flatten.reject{|v| v.length.eql?(1)}.map(&:length).min
  min_predicate = lambda { |a| a.length == min_length }
  bsq = g.find{ |k,v| v.values.any?(min_predicate)}
  ssq = bsq[1].find{|k, v| min_predicate.call(v)} unless bsq.nil?
  values_available = ssq[1]
  cell = "#{bsq.first}#{ssq.first}"
  puts "We picked #{cell}: #{values_available}"

  # pick a value for the square
  values_available.chars.each do |v|
    next if invalid?(g, cell, v)
    puts "Proceeding with value #{v} for #{cell}"
    g2 = Marshal.load(Marshal.dump(g))
    g2[bsq.first][ssq.first] = v
    remove_v(g2, cell, v)

    return g2 unless solve(g2).nil?
  end
  
  return nil
end

def invalid?(grid, cell, value)
  bsq, row, col = cell.chars

  row_neighbors = ROWS.find{|s| s.include?(bsq)}.gsub(bsq, '').chars
  row_values = grid.select{ |k, v| row_neighbors.include?(k) }
    .map{ |k, v| v.select { |k1, v1| k1[0].eql?(row) && v1.length == 1 }}
    .map(&:values).flatten

  col_neighbors = COLS.find{|s| s.include?(bsq)}.gsub(bsq, '').chars
  col_values = grid.select{ |k, v| col_neighbors.include?(k) }
    .map{ |k, v| v.select { |k1, v1| k1[1].eql?(col) && v1.length == 1 }}
    .map(&:values).flatten

  cell_values = grid[bsq]
    .select { |k,v| v.length == 1 }
    .reject { |k,v| k.eql?("#{row}#{col}") }
    .values

  neighbor_values = (row_values + col_values + cell_values).flatten

  return neighbor_values.include?(value)
end

def remove_v(grid, cell, value)
  bsq, row, col = cell.chars

  row_neighbors = ROWS.find{|s| s.include?(bsq)}.gsub(bsq, '').chars
  grid.select{ |k, v| row_neighbors.include?(k) }.each do |k, v| 
    v.select { |k1, v1| k1[0].eql?(row) && v1.length != 1 }
      .each { |k2, v2| grid[k][k2] = v2.gsub(value, '') }
  end

  col_neighbors = COLS.find{|s| s.include?(bsq)}.gsub(bsq, '').chars
  grid.select{ |k, v| col_neighbors.include?(k) }
    .each{ |k, v| v.select { |k1, v1| k1[1].eql?(col) && v1.length != 1 }
    .each { |k2, v2| grid[k][k2] = v2.gsub(value, '') }}

  cell_values = grid[bsq]
    .select { |k,v| v.length != 1 }
    .each { |k, v| grid[bsq][k] = v.gsub(value, '')}
end

def solved?(g)
  !g.find {|k, v| v.values.any?{|a| a.length != 1}}
end

def parse(k, v)
  # Generate A11, A12 etc. In this case k11, k12...k33
  list = (1..3).map(&:to_s)
  cells = list.product(list).map(&:join)
  default = '123456789'.tr(v.chars.map.reject{ |k| k.eql?('0') }.join, '')
  values = v.chars.map { |k| k.eql?('0') ? default : k }

  return { k => cells.zip(values).to_h }
end

def init
  JSON.parse(File.read('grid.json')) 
    .map{|k, v| parse(k, v)}.reduce(:merge)
end

solve(init)
