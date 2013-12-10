require "./lib/room"
require "./lib/player"
require "./lib/grue"
require "./lib/game_map"
require "json"

@@settings = {}
              # session_logs: false,
              # allow_two_way_corridors: false,
              # randomize_player_start: false,
              # randomize_grue_start: false,
@@messages = {}
@@commands =[:south, :west, :north, :east,
             :gems, :stats, :statistics,
             :i, :inventory, 
             :moves, :turns, :l, :look, 
             :q, :quit, :x, :exit, 
             :restart]

@info = [:gems, :i, :inventory, :stats, :statistics, :moves, :turns, :l, :look]
@game = [:q, :quit, :x, :exit, :restart]

@map = GameMap.instance
@player = Player.instance
@grue = Grue.instance

@@game_over = false

json = File.read("./config/game_config.json")
game_config = JSON.parse(json)

game_config["game_settings"].each_key do |setting|
  if setting.downcase.to_sym == :messages
    game_config["game_settings"][setting].each do |type, text|
      @@messages[type.downcase.to_sym] = text
    end
  else
    @@settings[setting.downcase.to_sym] = game_config["game_settings"][setting]
  end
end

@map.random_gems(@@settings[:random_gem_chance]) if @@settings[:random_gems]
@map.randomize_goal if @@settings[:randomize_goal]
@player.randomize_start if @@settings[:randomize_player_start]
@grue.randomize_start if @@settings[:randomize_grue_start]

def execute_command(command)
  if @map.valid_directions.include?(command)
    unless @player.move(command) == true
      print @@settings[:prompt]
      command = gets.chomp.to_sym
      execute_command(command)
    end
    if @player.room.has_grue?
      @grue.flee
      @player.get_loot
    end
  elsif @info.include?(command)
    get_info(command)
  # elsif command == :restart
  #   puts "restarter!"
  #   @@game_over = true
  #   @@settings[:end_game] = :restart
  else
    puts "quitter!"
    @@game_over = true
    @@settings[:end_game] = :quit
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
    puts "#{@player.inventory[:gems].to_s} gems"
    puts "#{@player.stats[:moves].to_s} moves\n"
  when :l, :look
    @player.get_loot
    @player.look(@@settings[:gems_required])
    @player.see
  end
end

def end_turn
  @player.stats[:turns] += 1
  @grue.move
  #puts "grue moves to #{@grue.room.color}. Current route: #{@grue.path.route}\n\n"
  you_lose if @grue.room.has_player?
end

def time_to_rest?
  @player.stats[:turns] % @@settings[:turns_between_rest] == 0
end

def rest
  @player.rest
  puts "[You rest for one turn.]"
  end_turn
end

def new_game?
  @player.stats[:turns] == 1
end

def victory_conditions_met?
  @player.inventory[:gems] >= @@settings[:gems_required]
end

def you_lose
  puts @@messages[:lose1].sample + @@messages[:lose2].sample
  @@game_over = true
end

def you_win
  puts @@messages[:win].sample
  @@game_over = true
  @@settings[:end_game] = :restart
end

def play
  until @@game_over
    if new_game?
      puts "\nYou find a gem on the floor, near a strange defunct machine, which seems to have several slots for other gems. These things might be your ticket home."
    end
    @player.look(@@settings[:gems_required])
    if time_to_rest?
      rest #duh.
    else
      print @@settings[:prompt]
      command_input = gets.chomp.to_sym
      if @@commands.include?(command_input)
        execute_command(command_input)
        if @map.valid_directions.include?(command_input)
          if @player.room.is_goal? 
            if victory_conditions_met?
              you_win
            end
          else
            end_turn
          end
        end
      else
        puts "Unrecognized command: " + command_input.to_s
      end
    end
  end
  return @@settings[:end_game]
end

play
