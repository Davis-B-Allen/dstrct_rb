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
    print_rules
    get_player_names_and_party
    next_turn
  end

  def print_rules
    puts "Here we should print the rules of DSTRCT"
  end

  def get_player_names_and_party
    puts "TODO: Capture player names and party affiliation"
  end

  def is_game_over?
    False
  end

  def next_turn
    @board.print_board
    complete_user_turn_input = fetch_complete_user_turn_input
  end

  def fetch_complete_user_turn_input
    map_id = capture_player_valid_tile_input
  end

  def capture_player_valid_tile_input
    player_choice = ""
    move_is_valid_code = check_valid_move(player_choice)
  end

  def check_valid_move(player_choice)

  end

end
