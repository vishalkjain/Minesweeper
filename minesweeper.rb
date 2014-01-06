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
    @board_array = Array.new(9){Array.new(9){Tile.new}}

    @masked_board = mask_board
  end

  def mask_board
  end

  def display
    @masked_board.each do |row|
      puts row
    end
  end

end

class Tile
  attr_reader :value

  def initialize
    @value = 0
  end

  def bomb?
    self.value == "b"
  end
end
