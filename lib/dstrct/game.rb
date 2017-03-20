require_relative 'game_settings.rb'

class Game

  def initialize
    puts "initializing game instance"
  end

  def play
    puts "Playing the game"
    puts GameSettings.num_to_alpha(2)
    puts GameSettings.alpha_to_num("A")
  end

end
