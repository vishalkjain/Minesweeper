class Minesweeper

  def initialize
    @board = Board.new
  end

  def run
    until @board.over?
      puts "Would you like to flag(f) or reveal(r)? "
      action = gets.chomp
      puts "Where?"
      coordinate = gets.chomp
      @board.take_action(action, coordinate)
    end
    @board.end_condition
  end


end