#!/usr/bin/env ruby

require 'securerandom'

def valid?(board, row, col, num, size)
  return false if board[row].include?(num)

  size.times do |r|
    return false if board[r][col] == num
  end

  start_row = row - row % 3
  start_col = col - col % 3

  (start_row...start_row + 3).each do |r|
    (start_col...start_col + 3).each do |c|
      return false if board[r][c] == num
    end
  end

  true
end

def fill_board(board, size)
  size.times do |row|
    size.times do |col|
      next unless board[row][col].zero?

      nums = (1..size).to_a.shuffle(random: SecureRandom)

      nums.each do |num|
        if valid?(board, row, col, num, size)
          board[row][col] = num
          return true if fill_board(board, size)

          board[row][col] = 0
        end
      end

      return false
    end
  end
  true
end

def generate_complete_sudoku()
  size = 3 * 3
  board = Array.new(size) { Array.new(size, 0) }
  fill_board(board, size)
  board
end

def create_puzzle(board, empty_cells)
  size = 3 * 3
  puzzle = board.map(&:dup)
  positions = (0...size).to_a.product((0...size).to_a).shuffle(random: SecureRandom)
  positions.first([empty_cells, size * size].min).each do |r, c|
    puzzle[r][c] = 0
  end
  
  puzzle
end

def board_full(board)
  board.each do |row|
    return false if row.include?(0)
  end
  true
end

def print_board(board)
  size = 9
  k = 3

  puts
  size.times do |r|
    if r.positive? && (r % 3).zero?
      line = ''
      (size * 2 + k).times do |c|
        line << (c.positive? && (c % (k * 2 + 2)).zero? ? '┼' : '─')
      end
      line[0] = ''
      line << '─' * k
      puts line
    end

    size.times do |c|
      print ' │' if c.positive? && (c % k).zero?

      val = board[r][c].zero? ? '.' : board[r][c]
      print " #{val}"
    end
    puts
  end
  puts
end

size = (3 * 3) * 9

puts "\nDifficulty:"
puts "1) Easy"
puts "2) Normal"
puts "3) Hard"

print "\nSelect: "
difficulty = gets.strip

empty_cells = case difficulty
  when '1' then (35 * size) / 100  #  35%
  when '2' then (45 * size) / 100  #  45%
  else ((55 * size) / 100 ) + 1    # ~55%
end

complete = generate_complete_sudoku()
puzzle   = create_puzzle(complete, empty_cells)
cp_puzzle  = puzzle

while cp_puzzle != complete
  print_board(cp_puzzle)

  if board_full(cp_puzzle)
    puts "Loser... :("
    puts "\n===== Correctly solved board ====="
    print_board(complete)
    exit
  end

  begin
    print "Select row(i): "
    i = gets.to_i
    print "Select col(j): "
    j = gets.to_i
    print "What number?: "
    n = gets[0].to_i

    block = puzzle[i-1][j-1]
    if block.zero?
      cp_puzzle[i-1][j-1] = n
      puts "Writed..."
    else
      puts "\nThis block was filled by default."
      sleep 2
      next
    end
  rescue
  end
end

print_board(complete)

puts "You Won..! :)"
