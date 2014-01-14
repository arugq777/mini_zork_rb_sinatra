require "./lib/room"
require "./lib/room_occupant"
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
    @game_over = false
    @restart = true

    import_settings_from_json
    import_map_from_json

    #set map class variables for Path, Grue and Player
    Path.set_map(@map)
    RoomOccupant.set_map(@map)

    start_room = initialize_starting_positions
    @player = Player.new(start_room[:player])
    @grue = Grue.new(start_room[:grue], start_room[:player])
    starting_output
  end

  def import_settings_from_json
    @settings = {}
    @messages = {}
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
  end

  def import_map_from_json
    @map = GameMap.new
    @map.random_gems(@settings[:random_gem_chance]) if @settings[:random_gems]
    @map.randomize_goal if @settings[:randomize_goal]
  end

  def initialize_starting_positions
    #initialize starting positions for player & grue
    starting_positions = {}
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
    starting_positions[:player] = player_start_room
    starting_positions[:grue] = grue_start_room
    return starting_positions
  end

  def starting_output
    @output_hash = {}
    @output_hash[:start] = @messages[:start].sample
    @output_hash[:look] = @player.look
    @output_hash[:sense] = @player.sense(@settings[:gems_required])
    @output_hash[:exits] = @player.list_exits 
    @info_hash = update_info_hash
  end

  def execute_command(command)
    if @map.valid_directions.include?(command)
      @output_hash[:move] = @player.move(command)
      if @player.room.has_grue?
        @output_hash[:grue_flees] = []
        @output_hash[:grue_flees] << @grue.flee(player)
        if @player.has_clairvoyance?
          @output_hash[:grue_flees] << "[grue flees to #{@grue.room.color}. Current route: #{@grue.path.route}"
        end
      end
      @output_hash[:loot] = @player.get_loot
      if @player.room.is_goal? && victory_conditions_met?
        you_win
      end
    elsif @@info.include?(command)
      get_info(command)
    elsif command == :rest
      rest
    elsif command == :quit
      puts "quitter!"
      @game_over = true
      @restart = false
    else
      puts "invalid command: #{command}"
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
      puts @player.look
      @player.see(@grue)
      puts @player.list_exits
    end
  end

  def update_info_hash
    @info_hash = {} 
    @info_hash[:player] = @player.stats
    if @player.has_clairvoyance?
      path = Path.new(@player.room.color, @map.goal)
      loot = "Gems can be found in: "
      @map.rooms.each_value do |room| 
        if room.flags[:loot]
          loot += room.color.to_s.capitalize + " [#{room.gems}]"
        end
      end
      @info_hash[:clairvoyance] = {
        grue: "Grue is in: #{@grue.room.color.to_s.capitalize}",
        grue_path: "Current path: #{@grue.path.route}",
        goal: "Goal is in #{@map.goal.to_s.capitalize}",
        goal_path: "Path to goal: #{path.route}",
        loot: loot
      } 
    end
    @info_hash
  end

  def rest
    @output_hash[:rest] =  @player.rest(@settings[:turns_between_rest])
    @output_hash[:rest] += " [You REST for one turn.]"
    end_turn
  end

  def you_lose
    @output_hash[:lose] =  @messages[:lose1].sample + @messages[:lose2].sample
    @output_hash[:lose] += " [YOU LOSE.]"
    @game_over = true
  end

  def you_win
    @output_hash[:win] =  @messages[:win].sample
    @output_hash[:win] += " [YOU WIN!]"
    @game_over = true
  end

  def end_turn
    @player.stats[:turns] += 1
    @player.stats[:rest_countdown] -= 1
    @output_hash[:look] = @player.look
    @output_hash[:exits] = @player.list_exits
    unless @grue.fled_this_turn
      @output_hash[:grue_move] = @grue.move(@player.room.color)
      you_lose if @grue.room.has_player?
    end
    @output_hash[:sense] = @player.sense(@settings[:gems_required])
    update_info_hash
  end

  def time_to_rest?
    @player.stats[:rest_countdown] == 0
  end

  def new_game?
    @player.stats[:turns] == 1
  end

  def victory_conditions_met?
    @player.inventory[:gems] >= @settings[:gems_required]
  end

  def output_for_this_turn
    @info_hash.each do |k, v|
      if v.is_a?(Array) && !v.empty?
        print "[#{k.to_s}]: "
        v.each do |array_string|
          print "#{array_string} "
        end
        puts ""
      else
        puts "[#{k.to_s}]: #{v}"
      end
    end
    @output_hash.each do |k, v|
      if v.is_a?(Array) && !v.empty?
        print "[#{k.to_s}]: "
        v.each do |array_string|
          print "#{array_string} "
        end
        puts ""
      else
        puts "[#{k.to_s}]: #{v}"
      end
    end
    # puts output_hash[:move] unless output_hash[:move].nil?
    # puts output_hash[:grue_flees] unless output_hash[:grue_flees].nil?
    # puts output_hash[:look]
    # puts output_hash[:loot] unless output_hash[:loot].nil?
  end



  def play(command)
    @grue.fled_this_turn = false
    unless @game_over
      @output_hash = {}
      @output_hash[:look] = @player.look
      #@output_hash[:sense] = @player.sense(@settings[:gems_required])
      if time_to_rest?
        rest #duh.
      else 
        execute_command(command)
        unless @output_hash[:move] == false || @output_hash[:move] == nil
          end_turn
        end
      end
    end
    return @output_hash
  end
end
