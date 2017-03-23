require_relative 'game_settings.rb'
require_relative 'board.rb'

class Game

  def initialize
    @rows = GameSettings::ROWS
    @columns = GameSettings::COLUMNS
    @board = Board.new
    @whose_turn = 1
    @num_turns = 0
    @congress_points_r = 0
    @congress_points_d = 0
    @player_names = []
    @p1_affiliation = ""
    @p2_affiliation = ""
    @player_affiliations = []
  end

  def play
    puts "playing game; the time is 1209\n\n"
    print_rules
    get_player_names_and_party
    next_turn
  end

  def print_rules
    puts("Welcome to DSTRCT\n\n")
    puts("DSTRCT is a game about gerrymandering.\n\n")
    puts("The game board is a #{@rows.to_s} by #{@columns.to_s} grid of " +
         "voters, each with a political preference: Democrat or Republican.")
    puts("Each player will assume the role of a political party (Democrat " +
         "or Republican) and will take turns to divide up the game board " +
         "into #{GameSettings::MAX_DISTRICTS.to_s} districts, each with a" +
         "maximum of #{GameSettings::MAX_DISTRICT_SIZE.to_s} voters.")
    puts("There are exactly the same number of Democratic voters as " +
         "Republican voters. However, with some clever choice of district " +
         "boundaries, you can obtain more political power than your opponent.")
    puts("Within each district the party with the most votes will win the " +
         "'Congress Point' for that district.")
    puts("A full district of #{GameSettings::MAX_DISTRICT_SIZE.to_s} voters " +
         "will earn 1 Congress Point.")
    puts("A district of fewer than #{GameSettings::MAX_DISTRICT_SIZE.to_s} " +
         "voters will earn proportionally less than 1 Congress Point.")
    puts("If there is a tie within a district, the congress points will be " +
         "split.\n\n")
  end

  def get_player_names_and_party
    p1_name = p2_name = ""
    p1_has_affiliation = p2_has_affiliation = false
    while p1_name == ""
      print "\nPlayer 1, please enter your name: "
      p1_name = $stdin.gets.chomp
      @player_names << p1_name
    end
    while !p1_has_affiliation
      puts("\nPlayer 1, please choose your party.")
      puts("For Democrat, enter 'D'")
      puts("For Republican, enter 'R'")
      puts("To choose a third party, enter 'other'")
      print "> "
      @p1_affiliation = $stdin.gets.chomp.downcase
      if @p1_affiliation == "d" || @p1_affiliation == "r"
        p1_has_affiliation = true
        @player_affiliations << @p1_affiliation == "d" ? 0 : 1
      elsif @p1_affiliation == "other"
        puts("Sorry, DSTRCT does not support victory for third parties, please choose either Democrat or Republican")
      else
        puts("Sorry, didn't understand that")
      end
    end
    while p2_name == ""
      print "\nPlayer 2, please enter your name: "
      p2_name = $stdin.gets.chomp
      @player_names << p2_name
    end
    while !p2_has_affiliation
      puts("\nPlayer 2, please choose your party.")
      puts("For Republican, enter 'R'") if @p1_affiliation == "d"
      puts("For Democrat, enter 'D'") if @p1_affiliation == "r"
      puts("To choose a third party, enter 'other'")
      print "> "
      @p2_affiliation = $stdin.gets.chomp.downcase
      if (@p2_affiliation == "d" && @p1_affiliation != "d") || (@p2_affiliation == "r" && @p1_affiliation != "r")
        p2_has_affiliation = true
        @player_affiliations << @p2_affiliation == "d" ? 0 : 1
      elsif @p2_affiliation == "other"
        print("Sorry, DSTRCT does not support victory for third parties, please choose either Democrat or Republican")
      else
        print("Sorry, didn't understand that")
      end
    end
    puts ""
  end

  def is_game_over?
    return false if @board.num_districts < GameSettings::MAX_DISTRICTS
    return !@board.available_moves_left?
  end

  def evaluate_game_and_print_result
    @board.find_remnant_groups
    puts("\nRESULTS\n-------\n")
    @board.print_board

    d_count = 0
    for district in @board.districts
      d_sum = district.map { |t| t.voter_preference_int }.inject(:+)
      d_len = district.length
      d_avg = d_sum.to_f / d_len.to_f
      d_cong_pt = d_len.to_f / GameSettings::MAX_DISTRICT_SIZE
      if d_avg > 0.5
        @congress_points_r += d_cong_pt
      elsif d_avg == 0.5
        @congress_points_r += (d_cong_pt / 2.0)
        @congress_points_d += (d_cong_pt / 2.0)
      else
        @congress_points_d += d_cong_pt
      end
      # puts "District: #{d_count}\nd_sum: #{d_sum}\nd_len: #{d_len}\nd_avg: #{d_avg}\nd_cong_pt:#{d_cong_pt}\ncongress_points_r: #{@congress_points_r}\ncongress_points_d: #{@congress_points_d}\n\n"
      d_count += 1
    end
    r_count = 0
    for rg in @board.remnant_groups
      r_sum = rg.map { |t| t.voter_preference_int }.inject(:+)
      r_len = rg.length
      r_avg = r_sum.to_f / r_len.to_f
      r_cong_pt = r_len.to_f / GameSettings::MAX_DISTRICT_SIZE
      if r_avg > 0.5
        @congress_points_r += r_cong_pt
      elsif r_avg == 0.5
        @congress_points_r += (r_cong_pt / 2.0)
        @congress_points_d += (r_cong_pt / 2.0)
      else
        @congress_points_d += r_cong_pt
      end
      # puts "Remnant: #{r_count}\nr_sum: #{r_sum}\nr_len: #{r_len}\nr_avg: #{r_avg}\nr_cong_pt:#{r_cong_pt}\ncongress_points_r: #{@congress_points_r}\ncongress_points_d: #{@congress_points_d}\n\n"
      r_count += 1
    end
    puts "\nThe Democrats won " + @congress_points_d.to_s + " congress points"
    puts "The Republicans won " + @congress_points_r.to_s + " congress points\n"
    if @congress_points_d > @congress_points_r
      puts "The Democrats win!\n"
    elsif @congress_points_d == @congress_points_r
      puts "It's a tie!\n"
    else
      puts "The Republicans win!\n"
    end
  end

  def next_turn
    @board.print_board
    valid_map_id, player_district_choice = fetch_complete_user_turn_input
    @board.add_tile_to_district(valid_map_id, player_district_choice)
    @whose_turn = @whose_turn == 1 ? 2 : 1
    @num_turns += 1
    if is_game_over?
      evaluate_game_and_print_result
    else
      next_turn
    end
  end

  def fetch_complete_user_turn_input
    valid_map_id = capture_player_valid_tile_input
    available_districts = @board.return_available_moves(valid_map_id)
    player_district_choice = capture_player_valid_district_input(available_districts)
    if player_district_choice == -1
      return fetch_complete_user_turn_input
    else
      return valid_map_id, player_district_choice
    end
  end

  def capture_player_valid_district_input(available_districts)
    new_district_available = @board.num_districts < GameSettings::MAX_DISTRICTS
    while true
      puts ""
      available_districts.each do |district_id|
        if district_id < @board.num_districts
          puts "Please enter '" + district_id.to_s + "' to add to district " + district_id.to_s
        else
          puts  "Please enter 'new' to create a new district and add this tile to it."
        end
      end
      puts "If you'd like to go back and choose a different tile, type 'back'"
      print "> "
      player_input = $stdin.gets.chomp
      if !!(player_input =~ /\A[0-9]+\z/)
        return player_input.to_i if available_districts.include?(player_input.to_i)
      elsif new_district_available && player_input.downcase == "new"
        return @board.num_districts
      elsif player_input.downcase == "back"
        return -1
      end
      puts "Sorry, didn't understand that."
    end
  end

  def capture_player_valid_tile_input
    player_input = ""
    move_is_valid_code = check_valid_move(player_input)
    while move_is_valid_code < 1
      case move_is_valid_code
        when -3
          puts "No available moves for this tile"
        when -2
          puts "Tile already belongs to a district!"
        when -1
          puts "Not a valid tile code"
      end
      print "\n#{@player_names[@whose_turn - 1]} (Player #{@whose_turn}), please choose a tile by column letter and row number (e.g. C4): "
      player_input = $stdin.gets.chomp
      move_is_valid_code = check_valid_move(player_input)
    end
    return player_input
  end

  def check_valid_move(player_input)
    # return codes key:
    # -3 -> no available moves for this tile, cannot add district, and cannot add tile to existing district
    # -2 -> no available moves for this tile, tile already belongs to district
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
    tile = @board.get_tile(row_index, col_index)
    return -2 if tile.district # if tile.district is not nil
    available_districts = @board.return_available_moves(player_input)
    return -3 if available_districts.length == 0
    return 1
  end

end
