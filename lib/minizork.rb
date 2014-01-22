require "./lib/room"
require "./lib/room_occupant"
require "./lib/player"
require "./lib/grue"
require "./lib/game_map"
require "json"

class MiniZork
  attr_accessor :game_settings, :all_settings, :messages, :restart, :game_over, :quit,
                :player, :map, :grue, :goal, :output_hash, :info_hash

  @@commands =[:south, :west, :north, :east,
               :gems, :stats, :statistics,
               :i, :inventory, :rest,
               :moves, :turns, :l, :look, 
               :q, :quit] #:restart

  @@info = [:gems, :i, :inventory, :stats, :statistics, :moves, 
            :turns, :l, :look]

  @@output_order = [:move, :grue_flees, :loot, :rest, :start, :look, 
                    :sense, :exits, :grue_move, :lose, :win]
  @@info_order = [:turns, :moves, :inventory, :rest_countdown]
  @@clairvoyance= [:grue, :grue_path, :goal, :goal_path, :loot]


  def initialize
    @game_over = false
    @quit = false

    import_settings_from_json
    import_map_from_json

    #set map class variables for Path, Grue and Player
    Path.set_map(@map)
    RoomOccupant.set_map(@map)

    @map.random_gems(@game_settings[:random_gem_chance]) if @game_settings[:random_gems]
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
    if @game_settings[:randomize_goal]
      @map.randomize_goal
    else
      @map.set_goal(@all_settings[:goal][:room].downcase.to_sym)
    end
  end

  def initialize_starting_positions
    #initialize starting positions for player & grue
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
    @output_hash[:start] = @messages[:start].sample
    @output_hash[:look]  = @player.look
    @output_hash[:sense] = @player.sense(@game_settings[:gems_required], @grue)
    @output_hash[:exits] = @player.list_exits 
    @output_hash[:loot]  = @player.get_loot
    @info_hash = update_info_hash
  end

  def execute_command(command)
    if @map.valid_directions.include?(command)
      @output_hash[:move] = @player.move(command)
      if @output_hash[:move]
        if @player.room.has_grue?
          @output_hash[:grue_flees] = []
          @output_hash[:grue_flees] << @grue.flee(player)
          if @player.has_clairvoyance?
            @output_hash[:grue_flees] << "[grue flees to #{@grue.room.color}. Current route: #{@grue.path.route}"
          end
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
      @game_over = true
      @quit = true
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
      @player.see(@grue) if @player.has_clairvoyance?
      puts @player.list_exits
    end
  end

  def update_info_hash
    @info_hash, loot, grue_path, goal_path = {},{},{},{} 
    @info_hash[:player] = @player.stats
    #I'll turn this into a seperate hash if I decide to expand inventory options.
    @info_hash[:player][:inventory] = @player.inventory
    if @player.has_clairvoyance?
      path = Path.new(@player.room.color, @map.goal)
      goal_path[:msg] = "Path to GOAL: "
      goal_path[:list] = path.route      
      grue_path[:msg] = "Current path: "
      grue_path[:list] = @grue.path.route
      loot[:msg] = "GEMS can be found in: "
      loot[:list] = []
      @map.rooms.each_value do |room| 
        if room.flags[:loot]
          loot[:list] << room.color.to_s.capitalize + " [#{room.gems}] "
        end
      end
      @info_hash[:clairvoyance] = {
        grue: "GRUE is in #{@grue.room.color.to_s.upcase}",
        grue_path: grue_path,
        goal: "GOAL is in #{@map.goal.to_s.upcase}",
        goal_path: goal_path,
        loot: loot
      } 
    end
    @info_hash
  end

  def rest
    @output_hash[:rest] =  @player.rest(@game_settings[:turns_between_rest])
    @output_hash[:rest] += " [You REST for one turn.]"
    end_turn
  end

  def you_lose
    @output_hash[:lose] =  @messages[:lose1].sample + @messages[:lose2].sample
    @output_hash[:lose] += " [YOU LOSE.]"
    @game_over = true
    @player.stats[:alive] = false
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
    @output_hash[:sense] = @player.sense(@game_settings[:gems_required], @grue)
    update_info_hash
  end

  def time_to_rest?
    @player.stats[:rest_countdown] == 0
  end

  def new_game?
    @player.stats[:turns] == 1
  end

  def victory_conditions_met?
    @player.inventory[:gems] >= @game_settings[:gems_required]
  end

  def print_output(print_order, hash_to_print)
    print_order.each do |key|
      unless hash_to_print[key].nil?
        if hash_to_print[key].is_a?(Array) && !hash_to_print[key].empty?
          print "[#{key.to_s}]: "
          hash_to_print[key].each do |array_string|
            print "#{array_string} "
          end
          puts ""
        else
          puts "[#{key.to_s}]: #{hash_to_print[key]}"
        end
      end
    end    
  end

  def output_for_this_turn
    print_output(@@info_order, @info_hash[:player])
    print_output(@@clairvoyance, @info_hash[:clairvoyance])
    print_output(@@output_order, @output_hash)
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
        if @output_hash[:move] == false
          puts "There is no exit to the #{command.to_s.upcase}!"
        else
          end_turn
        end
      end
    end
    return @output_hash
  end
end
