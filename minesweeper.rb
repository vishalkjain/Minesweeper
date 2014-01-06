require 'yaml'

class Minesweeper

  def initialize
    @board = Board.new
  end

  def run
    # puts "New game(n) or load a saved game(l)?"
#     new_or_saved = gets.chomp

    puts "Enter 's' at any time to save."

    until @board.over?
      @board.display
      puts "Would you like to flag(f) or reveal(r)? "
      action = gets.chomp

      if action == "s"
        save_game
        next
      end

      puts "Where?"
      coordinate = gets.chomp
      @board.take_action(action, coordinate)
    end

    @board.display

    if @board.won?
      puts "YOU WIN!!!"
    else
      puts "NICE TRY... you lose."
    end
  end

  def save_game
    save = self.to_yaml
    File.open("minesweeper_save.txt", "w") do |f|
      f.puts save
    end
  end
end

class Board
  BOMB_NUMBER = 10
  BOARD_SIZE = 9

  def initialize
    @board_array = set_board
    @flags = BOMB_NUMBER
  end

  def display
    @board_array.each do |row|
      row.each do |tile|

        if tile.flagged?
          print "f "
        elsif tile.hidden?
          print "_ "
        elsif tile.revealed?
          print tile.value.to_s + " "
        end
      end
      puts "\n"
    end
  end

  def set_board
    blank_board = Array.new(BOARD_SIZE){Array.new(BOARD_SIZE){Tile.new}}

    bomb_board = set_bombs(blank_board)
    finished_board = set_numbers(bomb_board)

    finished_board
  end

  def take_action(action, coordinate)
    coordinate_array = coordinate.split(",").map { |value| value.to_i }
    y =  coordinate_array[0]
    x =  coordinate_array[1]
    tile = @board_array[y][x]
    if action == "r"
      tile.reveal
      if @board_array[y][x].value == 0
        update_zeros(y,x)
      end
    elsif action == "f"
      @board_array[y][x].set_flag
      @flags -= 1
    else
      return puts "Invalid"
    end

  end

  def update_zeros(y, x)
    checkers=[[1,1], [1,0], [1,-1], [0,-1], [-1,-1], [-1,0], [-1,1], [0,1]]

    positions_to_visit = [[y,x]]
    positions_visited = []

    until positions_to_visit.empty?

      current_position = positions_to_visit.shift
      positions_visited << current_position

      checkers.each do |change|

        adjacent_coordinates = [current_position[0] + change[0], current_position[1] + change[1]]

        possible_y = adjacent_coordinates[0]
        possible_x = adjacent_coordinates[1]

        next if @board_array[possible_y].nil? || possible_y < 0
        next if @board_array[possible_y][possible_x].nil? || possible_x < 0

        possible_tile = @board_array[possible_y][possible_x]

        if possible_tile.value == 0
          possible_tile.reveal
          positions_to_visit << [possible_y, possible_x] unless positions_visited.include?([possible_y, possible_x])
        elsif possible_tile.value > 0
          possible_tile.reveal
        end

      end
    end
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

  def over?
    won? || lost?
  end

  def bombs
    bombs = []
    @board_array.each do |row|
      row.each do |tile|
        if tile.bomb?
          bombs << tile
        end
      end
    end
    bombs
  end

  def won?

    bomb_tiles = bombs
    return false if @flags != 0

    bomb_tiles.each do |tile|
      if !tile.flagged?
       return false
      end
    end

    true
  end

  def lost?
    @board_array.each do |row|
      row.each do |tile|
        if tile.bomb? && tile.revealed?
          return true
        end
      end
    end
    false
  end

end

class Tile
  attr_accessor :value

  def initialize
    @value = 0
    @hidden = true
    @revealed = false
    @flagged = false
  end

  def bomb?
    self.value == "b"
  end

  def make_bomb
    self.value = "b"
  end

  def set_flag
    @flagged = true
  end

  def flagged?
    @flagged
  end

  def reveal
    @revealed = true
    @hidden = false
  end

  def revealed?
    @revealed
  end

  def hidden?
    @hidden
  end
end
m = Minesweeper.new
m.run
