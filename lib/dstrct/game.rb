require_relative 'game_settings.rb'
require_relative 'board.rb'

class Game

  def initialize
    # puts "initializing game instance"
    @rows = GameSettings::ROWS
    @columns = GameSettings::COLUMNS
    @board = Board.new
  end

  def play
    @board.print_board_simple
  end

end
