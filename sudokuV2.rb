#!/usr/bin/env ruby

require 'json'

ROWS = [ 'ABC', 'DEF', 'GHI' ]
COLS = [ 'ADG', 'BEH', 'CFI' ]

def solve(g)
  if(solved?(g))
    puts 'solved'
    puts "#{g}"
    return g
  end

  # pick an unsolved square
  # pick square with least values possible
  min_length = g.values.map(&:values).flatten.reject{|v| v.length.eql?(1)}.map(&:length).min
  bsq = g.find{ |k,v| v.values.any?{|a| a.length == min_length }}
  ssq = bsq[1].find{|k, v| v.length == min_length } unless bsq.nil?
  values_available = ssq[1]
  cell = "#{bsq.first}#{ssq.first}"
  #puts "We picked #{cell}: #{values_available}"

  # pick a value for the square
  values_available.chars.each do |v|
    g2 = Marshal.load(Marshal.dump(g))
    g2[bsq.first][ssq.first] = v
    next if remove_v(g2, cell, v).nil?

    puts "Proceeding with value #{v} for #{cell}"

    return g2 unless solve(g2).nil?
  end
  
  return nil
end

def invalid?(grid, cell, value)
  puts "invalid?"
  bsq, row, col = cell.chars
  grid[bsq]["#{row}#{col}"] = value

  row_neighbors = ROWS.find{|s| s.include?(bsq)}.gsub(bsq, '').chars
  col_neighbors = COLS.find{|s| s.include?(bsq)}.gsub(bsq, '').chars

  return (
    grid.slice(*row_neighbors)
    .map{ |k, v| v.select { |k1, v1| k1[0].eql?(row) && v1.length == 1 }}
    .map(&:values)
    .any? { |vs| vs.include?(value) } ||

    grid.slice(*col_neighbors)
    .map{ |k, v| v.select { |k1, v1| k1[1].eql?(col) && v1.length == 1 }}
    .map(&:values)
    .any? { |vs| vs.include?(value) }
  )
end

def remove_v(grid, cell, value)
  puts "remove_v"
  bsq, row, col = cell.chars

  return if invalid?(grid, cell, value)

  row_neighbors = ROWS.find{|s| s.include?(bsq)}.gsub(bsq, '').chars
  col_neighbors = COLS.find{|s| s.include?(bsq)}.gsub(bsq, '').chars

  return if grid.slice(*row_neighbors).any? do |k, v| 
    v.select { |k1, v1| k1[0].eql?(row) && v1.length != 1 }
      .any? { |k2, v2| invalid?(grid, "#{k}#{k2}", v2.gsub(value, '')) }
  end

  return if grid.slice(*col_neighbors).any? do |k, v| 
    v.select { |k1, v1| k1[1].eql?(col) && v1.length != 1 }
      .any? { |k2, v2| invalid?(grid, "#{k}#{k2}", v2.gsub(value, '')) }
  end

  return if grid[bsq].select { |k,v| v.length != 1 }.any? do |k, v|
    invalid?(grid, "#{bsq}#{k}", v.gsub(value, ''))
  end

  return true
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
  JSON.parse(File.read('grid2.json')) 
    .map{|k, v| parse(k, v)}.reduce(:merge)
end

solve(init)
