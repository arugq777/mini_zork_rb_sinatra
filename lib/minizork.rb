require "./lib/room"
require "./lib/room_occupant"
require "./lib/player"
require "./lib/grue"
require "./lib/game_map"
require "./lib/gameplay"
require "json"

class MiniZork
  include Gameplay
  attr_accessor :game_settings, :all_settings, :messages, :restart, :game_over, 
                :quit, :player, :map, :grue, :goal, :output_hash, :info_hash

  @@commands =[:south, :west, :north, :east, :rest, :q, :quit] #:restart

  @@info = [:gems, :i, :inventory, :stats, :statistics, :moves, 
            :turns, :l, :look]

  def initialize
    @game_over = false
    @quit = false

    import_settings_from_json
    import_map_from_json

    #set map class variables for Path, Grue and Player
    Path.set_map(@map)
    RoomOccupant.set_map(@map)
    additional_map_settings

    start_room = initialize_starting_positions
    @player = Player.new(start_room[:player], @all_settings[:player])
    @grue = Grue.new(start_room[:grue], start_room[:player], @all_settings[:grue])
    starting_output
  end

  def import_settings_from_json
    json = File.read("./config/game_config.json")
    @all_settings = JSON.parse(json, symbolize_names: true)
    @game_settings = @all_settings[:game]
    @messages = @all_settings[:game][:messages]
  end

  def import_map_from_json
    json = File.read("./config/map_config.json")
    @map = GameMap.new(json)
  end

  def additional_map_settings

    if @game_settings[:random_gems]
      @map.random_gems(@game_settings[:random_gem_chance]) 
    end

    if @game_settings[:randomize_goal]
      @map.randomize_goal
    else
      @map.set_goal(@all_settings[:goal][:room].downcase.to_sym)
    end
  end

  def initialize_starting_positions # for both player & grue
    starting_positions = {}

    [:player, :grue].each do |x|
      if @all_settings[x][:room].is_a?(String)
        @all_settings[x][:room] = @all_settings[x][:room].downcase.to_sym
      end
    end

    if @game_settings[:randomize_player_start]
      player_start_room = @map.rooms.keys.sample
    else
      player_start_room = @all_settings[:player][:room]
    end 

    if @game_settings[:randomize_grue_start]
      grue_start_room = player_start_room
      until grue_start_room != player_start_room
        grue_start_room = @map.rooms.keys.sample
      end
    else
      grue_start_room = @all_settings[:grue][:room]
    end

    starting_positions[:player] = player_start_room
    starting_positions[:grue] = grue_start_room
    
    return starting_positions
  end

  def starting_output
    @output_hash = {}
    @output_hash[:turn]  = "Turn 1"
    @output_hash[:start] = @messages[:start].sample
    @output_hash[:look]  = @player.look
    @output_hash[:sense] = @player.sense(@game_settings[:gems_required], @grue)
    @output_hash[:exits] = @player.list_exits 
    @output_hash[:loot]  = @player.get_loot
    @info_hash = update_info_hash
  end
end
