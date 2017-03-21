require_relative 'game_settings.rb'

class Tile
  attr_reader :voter_preference
  attr_accessor :district
  attr_reader :row_index
  attr_reader :col_index

  def initialize(row_index, col_index, voter_preference_int)
    @row_index = row_index
    @col_index = col_index
    @voter_preference_int = voter_preference_int
    @map_id = GameSettings.convert_coords_to_map_id(row_index, col_index)
    @voter_preference = (voter_preference_int == 0 ? "D" : "R")
    @district = nil
  end

end
