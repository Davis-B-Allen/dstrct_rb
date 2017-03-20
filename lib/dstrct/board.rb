require_relative 'game_settings.rb'
require_relative 'tile.rb'

class Board

  def initialize
    # puts "Board Created!"
    @rows = GameSettings::ROWS
    @columns = GameSettings::COLUMNS
    @tilegrid = []
    set_up_board
  end

  def set_up_board
    num_zeroes = num_ones = ((@rows * @columns)/2).ceil
    pool = (Array.new(num_ones, 1) + Array.new(num_zeroes, 0)).shuffle
    @rows.times do |i|
      row = []
      @columns.times do |j|
        tile = Tile.new(i,j,pool.pop)
        row << tile
      end
      @tilegrid << row
    end
  end

  def print_board_simple
    @tilegrid.each_with_index do |row, i|
      line = " "
      row.each_with_index do |tile, j|
        line += (tile.voter_preference + " ")
      end
      puts line
    end
  end

end
