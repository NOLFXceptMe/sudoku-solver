#!/usr/bin/env ruby

require 'json'

ROWS = [ 'ABC', 'DEF', 'GHI' ]
COLS = [ 'ADG', 'BEH', 'CFI' ]

def solve(g)
  if(solved?(g))
    puts "#{write(g)}"
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
    next if remove_v(g2, cell, v).nil?

    #puts "Proceeding with value #{v} for #{cell}"

    return g2 unless solve(g2).nil?
  end
  
  return nil
end

def invalid?(grid, cell, value)
  bsq, row, col = cell.chars
  grid[bsq]["#{row}#{col}"] = value

  return false if value.length != 1

  #puts "invalid?"

  return (
    row_neighbors(bsq).any? do |r|
      grid[r].any? { |k, v| k[0].eql?(row) && v.length == 1 && v.include?(value) }
    end ||

    col_neighbors(bsq).any? do |c|
      grid[c].any? { |k, v| k[1].eql?(col) && v.length == 1 && v.include?(value) }
    end
  )
end

def remove_v(grid, cell, value)
  #puts "remove_v"

  bsq, row, col = cell.chars

  return if invalid?(grid, cell, value)
  return if grid[bsq].any? { |k, v| v.length != 1 && invalid?(grid, "#{bsq}#{k}", v.gsub(value, '')) }

  return if row_neighbors(bsq).any? do |r|
    grid[r].any? { |k, v| k[0].eql?(row) && v.length != 1 && invalid?(grid, "#{r}#{k}", v.gsub(value, '')) }
  end

  return if col_neighbors(bsq).any? do |c|
    grid[c].any? { |k, v| k[1].eql?(col) && v.length != 1 && invalid?(grid, "#{c}#{k}", v.gsub(value, '')) }
  end

  return true
end

def row_neighbors(bsq)
  ROWS.find{|s| s.include?(bsq)}.gsub(bsq, '').chars
end

def col_neighbors(bsq)
  COLS.find{|s| s.include?(bsq)}.gsub(bsq, '').chars
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

def write(g)
  g.map { |k, v| [k, v.values.join] }.to_h
end

def init
  JSON.parse(File.read(ARGV[0]))
    .map{|k, v| parse(k, v)}.reduce(:merge)
end

solve(init)
