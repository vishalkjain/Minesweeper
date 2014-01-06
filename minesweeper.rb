require 'yaml'
require 'time'
require 'debugger'
class Minesweeper

  def initialize
    @board = Board.new
  end

  def run
    start_screen
    input_loop
    display_end_condition
  end

  def input_loop
    until @board.over?
      start_time = Time.now
      @board.display

      puts "Would you like to flag(f) or reveal(r)? "
      action = gets.chomp

      if action == "s"
        save_game
        next
      elsif action == "b"
        show_leaderboard
        next
      end

      puts "Where?"
      @board.take_action(action,gets.chomp)

      @board.seconds_so_far += (Time.now - start_time)
    end
  end

  def start_screen
    puts "New game(n) or load a saved game(l)?"
    new_or_saved = gets.chomp

    if new_or_saved == "l"
      load_game
    end

    puts "Enter 's' at any time to save. Enter 'b' at any time to see leaderboard."
  end

  def display_end_condition
    @board.reveal_all_bombs

    @board.display

    if @board.won?
      puts "YOU WIN!!! It took #{@board.seconds_so_far} seconds"
      save_to_leaderboard
      show_leaderboard
    else
      puts "NICE TRY... you lose, and it only took you #{@board.seconds_so_far} seconds."
    end
  end

  def save_game
    save = @board.to_yaml
    File.open("minesweeper_save.txt", "w") do |f|
      f.puts save
    end
  end

  def load_game
    saved_board = File.read("minesweeper_save.txt")
    @board = YAML::load(saved_board)
  end

  def save_to_leaderboard
    leaderboard_array = File.readlines("leaderboard.txt")
    leaderboard_array.map! { |time| time.to_f }
    leaderboard_array << @board.seconds_so_far
    leaderboard_array.sort!

    File.open("leaderboard.txt", "w") do |f|
      leaderboard_array.each do |time|
        f.puts time.to_s
      end
    end
  end

  def show_leaderboard
    leaderboard_array = File.readlines("leaderboard.txt")
    puts "Leaderboard:"
    leaderboard_array.each_with_index { |time, index| puts "#{index+1}: #{time}" }
  end
end


class Board
  attr_accessor :seconds_so_far

  BOMB_NUMBER = 1
  BOARD_SIZE = 5

  def initialize
    @board_array = set_board
    @flags = BOMB_NUMBER
    @seconds_so_far = 0
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
    blank_board = Array.new(BOARD_SIZE) { Array.new(BOARD_SIZE) { Tile.new } }

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
        #debugger
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
      rand_x = rand(BOARD_SIZE)
      rand_y = rand(BOARD_SIZE)
      next if board[rand_x][rand_y].bomb?

      board[rand_x][rand_y].make_bomb
      bombs_placed += 1
    end

    board
  end

  def reveal_all_bombs
    bombs.each { |bomb| bomb.reveal}
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
