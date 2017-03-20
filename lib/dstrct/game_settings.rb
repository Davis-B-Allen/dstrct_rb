module GameSettings

  # For use in helping with readable map IDs
  NUM_ALPHA_NUMS = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  NUM_ALPHA_ALPHAS = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
  NUM_ALPHA_MAP = {
                    0 => "A",
                    1 => "B",
                    2 => "C",
                    3 => "D",
                    4 => "E",
                    5 => "F",
                    6 => "G",
                    7 => "H",
                    8 => "I",
                    9 => "J",
                  }

  # Game Settings
  MAX_DISTRICT_SIZE = 7
  ROWS = 6
  COLUMNS = 7
  MAX_DISTRICTS = 6

  def GameSettings.num_to_alpha(some_int)
    NUM_ALPHA_MAP[some_int]
  end

  def GameSettings.alpha_to_num(some_str)
    NUM_ALPHA_MAP.key(some_str)
  end

  def GameSettings.convert_coords_to_map_id(row_index, col_index)
    NUM_ALPHA_MAP[row_index] + (col_index + 1).to_s
  end

end
