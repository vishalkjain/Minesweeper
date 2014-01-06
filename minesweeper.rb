class Minesweeper

  def initialize
    @board = Board.new
  end

  def run
    until @board.over?
      @board.display
      puts "Would you like to flag(f) or reveal(r)? "
      action = gets.chomp
      puts "Where?"
      coordinate = gets.chomp
      @board.take_action(action, coordinate)
    end
    @board.end_condition
  end
end

class Board
  BOMB_NUMBER = 10

  def initialize
    @board_array = set_board
    @masked_board = mask_board
  end

  def mask_board
  end

  def display
    @board_array.each do |row|
      row.each do |tile|
        print tile.value
      end
      puts
    end
  end

  def set_board
    blank_board = Array.new(9){Array.new(9){Tile.new}}

    bomb_board = set_bombs(blank_board)
    finished_board = set_numbers(bomb_board)

    finished_board
  end

  def set_bombs(board)
    bombs_placed = 0

    until bombs_placed == BOMB_NUMBER
      rand_x = rand(9)
      rand_y = rand(9)
      next if board[rand_x][rand_y].bomb?

      board[rand_x][rand_y].make_bomb
      bombs_placed += 1
    end

    board
  end

  def set_numbers(board)
    checkers=[[1,1], [1,0], [1,-1], [0,-1], [-1,-1], [-1,0], [-1,1], [0,1]]

    board.each_with_index do |row, y|
      row.each_with_index do |tile, x|
        next if tile.bomb?

        checkers.each do |change|
          adjacent_coordinates = [y + change[0], x + change[1]]
          possible_y = adjacent_coordinates[0]
          possible_x = adjacent_coordinates[1]

          next if board[possible_y].nil? || possible_y < 0
          next if row[possible_x].nil? || possible_x < 0

          adjacent_tile = board[possible_y][possible_x]

          if adjacent_tile.bomb?
            tile.value += 1
          end

        end
      end
    end

    board
  end
end

class Tile
  attr_accessor :value

  def initialize
    @value = 0
  end

  def bomb?
    self.value == "b"
  end

  def make_bomb
    self.value = "b"
  end

  def set_flag
    self.value = "f"
  end
end

b = Board.new
b.display