require_relative 'game_settings.rb'
require_relative 'tile.rb'

class Board

  def initialize
    # puts "Board Created!"
    @rows = GameSettings::ROWS
    @columns = GameSettings::COLUMNS
    @tilegrid = []
    @unplayed_tiles = []
    @vertical_borders = []
    @horizontal_borders = []
    set_up_board
  end

  def set_up_board
    num_zeroes = num_ones = ((@rows * @columns)/2).ceil
    pool = (Array.new(num_ones, 1) + Array.new(num_zeroes, 0)).shuffle
    @rows.times do |i|
      tilegrid_row = []
      vert_row = []
      hori_row = [] if i < (@rows - 1)
      @columns.times do |j|
        tile = Tile.new(i, j, pool.pop)
        tilegrid_row << tile
        @unplayed_tiles << tile
        vert_row << nil if j < (@columns - 1)
        hori_row << nil if i < (@rows - 1)
      end
      @tilegrid << tilegrid_row
      @vertical_borders << vert_row
      @horizontal_borders << hori_row if i < (@rows - 1)
    end
  end

  def print_board_simple
    @tilegrid.each do |row|
      line = " "
      row.each { |tile| line += (tile.voter_preference + " ") }
      puts line
    end
  end

  def print_board
    # Print header and column numbers
    spacing = "    "
    header_row = spacing
    @columns.times { |i| header_row += "    " + (i + 1).to_s + "   " }
    puts "\n" + header_row + "\n"

    puts spacing + ("-------" * @columns) + ("-" * (@columns + 1))

    @rows.times do |j|
      row1 = row2 = row3 = row4 = ""
      row1 += spacing + "|"
      row2 = row2 + GameSettings.num_to_alpha(j) + spacing[0..-2] + "|"
      row3 += spacing + "|"
      row4 += spacing
      @columns.times do |k|
        row2 += "  "
        tile = @tilegrid[j][k]
        if tile.district.nil?
          row2 += " " + tile.voter_preference + " "
        else
          row2 += tile.voter_preference + tile.district.to_s + tile.voter_preference
        end
        row2 += "  "
        if k < (@columns - 1)
          vert = @vertical_borders[j][k]
          row1 += vert.nil? ? "       |" : "        "
          row2 += vert.nil? ? "|" : vert.to_s
          row3 += vert.nil? ? "       |" : "        "
        end
        if j < (@rows - 1)
          horizontal = @horizontal_borders[j][k]
          row4 += horizontal.nil? ? "--------" : "   " + horizontal.to_s + "-   "
        end
      end
      row4 += "-" if j < (@rows - 1)
      row1 += "       |"
      row2 += "|"
      row3 += "       |"
      puts row1
      puts row2
      puts row3
      puts row4 if j < (@rows - 1)
    end

    puts spacing + ("-------" * @columns) + ("-" * (@columns + 1))
  end

end
