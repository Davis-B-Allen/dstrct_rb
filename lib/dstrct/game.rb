require_relative 'game_settings.rb'
require_relative 'board.rb'

class Game

  def initialize
    # puts "initializing game instance"
    @rows = GameSettings::ROWS
    @columns = GameSettings::COLUMNS
    @board = Board.new
    @whose_turn = 1
    @num_turns = 0
    # Uncomment and make use of the following
    # @congress_points_r = 0
    # @congress_points_d = 0
    # @player_names = []
    # @p1_affiliation = ""
    # @p2_affiliation = ""
    # @player_affiliations = []
  end

  def play
    print_rules
    get_player_names_and_party
    next_turn
  end

  def print_rules
    puts "Here we should print the rules of DSTRCT"
  end

  def get_player_names_and_party
    # TODO actually implement this
    puts "TODO: Capture player names and party affiliation"
  end

  def is_game_over?
    # TODO actually implement is_game_over? logic
    false
  end

  def evaluate_game_and_print_result
    # TODO implement this
  end

  def find_all_contiguous_undistricted_tiles(tile, remnant_group)
    # TODO implement this
  end

  def next_turn
    @board.print_board
    valid_map_id, player_district_choice = fetch_complete_user_turn_input
    if player_district_choice == @board.districts.length
      @board.districts << []
    else
      @board.update_borders(valid_map_id, player_district_choice)
    end
    row_index, col_index = GameSettings.convert_valid_map_id_to_coords(valid_map_id)
    tile = @board.tilegrid[row_index][col_index]
    @board.unplayed_tiles.delete(tile)
    @board.played_tiles << tile
    tile.district = player_district_choice
    @board.districts[player_district_choice] << tile
    @whose_turn = @whose_turn == 1 ? 2 : 1
    @num_turns += 1
    if is_game_over?
      puts "Game Over!"
      # TODO uncomment the following and implement it
      # evaluate_game_and_print_result
    else
      next_turn
    end
  end

  def fetch_complete_user_turn_input
    valid_map_id = capture_player_valid_tile_input
    available_districts = return_available_moves(valid_map_id)
    player_district_choice = capture_player_valid_district_input(available_districts)
    if player_district_choice == -1
      return fetch_complete_user_turn_input
    else
      return valid_map_id, player_district_choice
    end
  end

  def capture_player_valid_district_input(available_districts)
    new_district_available = @board.districts.length < GameSettings::MAX_DISTRICTS
    while true
      puts ""
      available_districts.each do |district_id|
        if district_id < @board.districts.length
          puts "Please enter '" + district_id.to_s + "' to add to district " + district_id.to_s
        else
          puts  "Please enter 'new' to create a new district and add this tile to it."
        end
      end
      puts "If you'd like to go back and choose a different tile, type 'back'"
      print "> "
      player_input = $stdin.gets.chomp
      if !!(player_input =~ /\A[0-9]+\z/)
        return player_input.to_i if (0..@board.districts.length-1).include?(player_input.to_i)
      elsif new_district_available && player_input.downcase == "new"
        return @board.districts.length
      elsif player_input.downcase == "back"
        return -1
      else
        puts "Sorry, didn't understand that."
      end
    end
  end

  def capture_player_valid_tile_input
    player_input = ""
    move_is_valid_code = check_valid_move(player_input)
    while move_is_valid_code < 1
      case move_is_valid_code
        when -3
          puts "Not a valid tile code"
        when -2
          puts "Tile already belongs to a district!"
        when -1
          puts "No available moves for this tile"
      end
      # TODO prepend player name / number to input prompt
      puts "Please choose a tile by column letter and row number (e.g. C4): "
      player_input = $stdin.gets.chomp
      move_is_valid_code = check_valid_move(player_input)
    end
    return player_input
  end

  def check_valid_move(player_input)
    # return codes key:
    # -3 -> cannot add district, and cannot add tile to existing district
    # -2 -> no available moves for this tile
    # -1 -> not a valid tile code
    # 0 -> no input, don't return error message, just prompt again
    # 1 -> valid tile code with available moves
    return 0 if player_input.length == 0
    # TODO Change the following to account for two-digit column indices
    return -1 if player_input.length != 2
    return -1 if !(player_input[-1] =~ /\A[0-9]+\z/)
    return -1 if !GameSettings.is_valid_map_id_row_char(player_input[0].upcase)
    return -1 if !GameSettings.is_valid_map_id_col_num(player_input[-1].to_i - 1)
    row_index, col_index = GameSettings.convert_valid_map_id_to_coords(player_input)
    tile = @board.tilegrid[row_index][col_index]
    return -2 if tile.district # if tile.district is not nil
    available_districts = return_available_moves(player_input)
    return -3 if available_districts.length == 0
    return 1
  end

  def return_available_moves(valid_map_id)
    available_districts = []
    row_index, col_index = GameSettings.convert_valid_map_id_to_coords(valid_map_id)
    for pair in [[1, 0], [0, 1], [-1, 0], [0, -1]]
      row_adjacent = row_index + pair[0]
      col_adjacent = col_index + pair[1]
      if 0 <= row_adjacent && row_adjacent < @rows && 0 <= col_adjacent && col_adjacent < @columns
        tile_adjacent = @board.tilegrid[row_adjacent][col_adjacent]
        if tile_adjacent.district
          if @board.districts[tile_adjacent.district].length < GameSettings::MAX_DISTRICT_SIZE
            if !available_districts.include?(tile_adjacent.district)
              available_districts << tile_adjacent.district
            end
          end
        end
      end
    end
    if @board.districts.length < GameSettings::MAX_DISTRICTS
      available_districts << @board.districts.length
    end
    return available_districts
  end

end
