require "./lib/room"
require "./lib/player"
require "./lib/grue"
require "./lib/game_map"
require "json"

class MiniZork
  attr_accessor :settings, :messages, :restart, :game_over, 
              :player, :map, :grue, :goal, :output_hash, :info_hash

  @@commands =[:south, :west, :north, :east,
               :gems, :stats, :statistics,
               :i, :inventory, :rest,
               :moves, :turns, :l, :look, 
               :q, :quit] #:restart

  @@info = [:gems, :i, :inventory, :stats, :statistics, :moves, :turns, :l, :look]
  @@game = [:q, :quit] #:restart

  def initialize
    @settings = {}
    @messages = {}

    @game_over = false
    @restart = true

    #import settings from JSON
    json = File.read("./config/game_config.json")
    game_config = JSON.parse(json)

    game_config["game_settings"].each_key do |setting|
      if setting.downcase.to_sym == :messages
        game_config["game_settings"][setting].each do |type, text|
          @messages[type.downcase.to_sym] = text
        end
      else
        @settings[setting.downcase.to_sym] = game_config["game_settings"][setting]
      end
    end

    #initialize the map
    @map = GameMap.instance
    @map.random_gems(@settings[:random_gem_chance]) if @settings[:random_gems]
    @map.randomize_goal if @settings[:randomize_goal]

    #initialize starting positions for player & grue
    if @settings[:randomize_player_start]
      player_start_room = @map.rooms.keys.sample
    else
      player_start_room = game_config["player_settings"]["room"].downcase.to_sym
    end 

    if @settings[:randomize_grue_start]
      grue_start_room = player_start_room
      until grue_start_room != player_start_room
        grue_start_room = @map.rooms.keys.sample
      end
    else
      grue_start_room = game_config["grue_settings"]["room"].downcase.to_sym
    end

    @player = Player.new(player_start_room)
    @grue = Grue.new(grue_start_room, player_start_room)
  end

  def execute_command(command)
    if @map.valid_directions.include?(command)
      unless @player.move(command) == true
        print @settings[:prompt]
        command = gets.chomp.to_sym
        execute_command(command)
      end
      if @player.room.has_grue?
        @grue.flee(player)
        puts "[grue flees to #{@grue.room.color}. Curent route: #{@grue.path.route}"
        @player.get_loot
      end
    elsif @@info.include?(command)
      get_info(command)
    elsif command == :rest
      @player.rest(@player.stats[:rest_countdown])
      end_turn
    # elsif command == :restart
    #   puts "restarter!"
    #   @game_over = true
    #   @restart = true
    #   end_turn
    else
      puts "quitter!"
      @game_over = true
      @restart = false
    end
  end

  def get_info(command)
    case command
    when :gems, :i, :inventory
      puts "\nYou have #{@player.inventory[:gems].to_s} gems"
    when :moves, :turns
      puts "\nYou've made #{@player.stats[:moves].to_s} moves in #{@player.stats[:turns].to_s} turns"
    when :stats, :statistics
      puts "\nTurn #{@player.stats[:turns].to_s}"
      puts "\nTurns til rest: #{@player.stats[:rest_countdown]}"
      puts "#{@player.inventory[:gems].to_s} gems"
      puts "#{@player.stats[:moves].to_s} moves\n"
    when :l, :look
      #@player.get_loot
      @player.look(@player.stats[:rest_countdown])
      @player.see(@grue)
    end
  end

  def end_turn
    @player.stats[:turns] += 1
    @player.stats[:rest_countdown] -= 1
    unless @grue.fled_this_turn
      @grue.move(@player.room.color)
      puts "[grue moves to #{@grue.room.color}. Current route: #{@grue.path.route}]"
      you_lose if @grue.room.has_player?
    end
    @grue.fled_this_turn = false
  end

  def time_to_rest?
    @player.stats[:rest_countdown] == 0
  end

  def rest
    @player.rest(@settings[:turns_between_rest])
    puts "[You rest for one turn.]"
    end_turn
  end

  def new_game?
    @player.stats[:turns] == 1
  end

  def victory_conditions_met?
    @player.inventory[:gems] >= @settings[:gems_required]
  end

  def you_lose
    puts @messages[:lose1].sample + @messages[:lose2].sample
    puts "[you lose.]"
    @game_over = true
  end

  def you_win
    puts @messages[:win].sample
    puts "[you win.]"
    @game_over = true
  end

  def play
    until @game_over
      if new_game?
        puts @messages[:start].sample
      end
      @player.look(@settings[:gems_required])
      if time_to_rest?
        rest #duh.
      else
        print @settings[:prompt]
        command_input = gets.chomp.to_sym
        if @@commands.include?(command_input)
          execute_command(command_input)
          if @map.valid_directions.include?(command_input)
            if @player.room.is_goal? && victory_conditions_met?
              you_win
            else
              end_turn
            end
          end
        else
          puts "Unrecognized command: " + command_input.to_s
        end
      end
    end
    return @game_over
  end
end

#mz = MiniZork.new
#mz.play
# while mz.restart
#   mz = MiniZork.new
#   mz.play
# end
