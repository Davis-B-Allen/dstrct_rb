require_relative 'game_settings.rb'
require_relative 'tile.rb'

class Board
  attr_reader :tilegrid
  attr_reader :districts
  attr_reader :unplayed_tiles
  attr_reader :played_tiles

  def initialize
    # puts "Board Created!"
    @rows = GameSettings::ROWS
    @columns = GameSettings::COLUMNS
    @tilegrid = []
    @unplayed_tiles = []
    @played_tiles = []
    @vertical_borders = []
    @horizontal_borders = []
    @districts = []
    # TODO Uncomment and make use of the following
    # @remnants = []
    # @remnant_groups = []
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

  def add_tile_to_district(valid_map_id, district_id)
    if district_id == @districts.length
      @districts << []
    else
      update_borders(valid_map_id, district_id)
    end
    row_index, col_index = GameSettings.convert_valid_map_id_to_coords(valid_map_id)
    tile = @tilegrid[row_index][col_index]
    @unplayed_tiles.delete(tile)
    @played_tiles << tile
    tile.district = district_id
    @districts[district_id] << tile
  end

  def return_available_moves(valid_map_id)
    available_districts = []
    row_index, col_index = GameSettings.convert_valid_map_id_to_coords(valid_map_id)
    for pair in [[1, 0], [0, 1], [-1, 0], [0, -1]]
      row_adjacent = row_index + pair[0]
      col_adjacent = col_index + pair[1]
      if 0 <= row_adjacent && row_adjacent < @rows && 0 <= col_adjacent && col_adjacent < @columns
        tile_adjacent = @tilegrid[row_adjacent][col_adjacent]
        if tile_adjacent.district
          if @districts[tile_adjacent.district].length < GameSettings::MAX_DISTRICT_SIZE
            if !available_districts.include?(tile_adjacent.district)
              available_districts << tile_adjacent.district
            end
          end
        end
      end
    end
    if @districts.length < GameSettings::MAX_DISTRICTS
      available_districts << @districts.length
    end
    return available_districts
  end

  def num_districts
    @districts.length
  end

  def get_tile(row_index, col_index)
    @tilegrid[row_index][col_index]
  end

  def update_borders(map_id, district)
    row_index, col_index = GameSettings.convert_valid_map_id_to_coords(map_id)
    same_district_neighbors = []
    tile = self.tilegrid[row_index][col_index]

    for pair in [[1, 0], [0, 1], [-1, 0], [0, -1]]
      row_adjacent = row_index + pair[0]
      col_adjacent = col_index + pair[1]
      if 0 <= row_adjacent && row_adjacent < @rows && 0 <= col_adjacent && col_adjacent < @columns
        tile_adj = @tilegrid[row_adjacent][col_adjacent]
        if tile_adj.district == district
          same_district_neighbors << tile_adj
        end
      end
      same_district_neighbors.each do |tile_adjacent|
        border_row_index = [tile.row_index, tile_adjacent.row_index].min
        border_col_index = [tile.col_index, tile_adjacent.col_index].min
        if tile.row_index == tile_adjacent.row_index
          @vertical_borders[border_row_index][border_col_index] = district
        elsif tile.col_index == tile_adjacent.col_index
          @horizontal_borders[border_row_index][border_col_index] = district
        end
      end
    end
  end

  def available_moves_left?
    @unplayed_tiles.each do |tile|
      if return_available_moves(tile.map_id).length > 0
        return true
      end
    end
    return false
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
          row4 += horizontal.nil? ? "--------" : "-   " + horizontal.to_s + "   "
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
