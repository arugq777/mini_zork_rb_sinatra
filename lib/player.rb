require "singleton"
require "./lib/room_occupant"

class Player < RoomOccupant
  include Singleton
  attr_accessor :stats, :inventory, :settings, :path_to_goal

  def initialize
    @settings = {}
    @inventory = {}
    @messages = {}
    @stats = {alive: true, turns: 1, moves: 0, rest_countdown: nil}

    json = File.read("./config/game_config.json")
    
    settings = JSON.parse(json)

    @stats[:rest_countdown] = settings["player_settings"]["stats"]["rest_countdown"]
    settings["player_settings"]["settings"].each do |key, bool|
      @settings[key.downcase.to_sym] = bool
    end

    settings["player_settings"]["inventory"].each do |item, amt|
      @inventory[item.downcase.to_sym] = amt
    end

    settings["player_settings"]["messages"].each do |message_type,txt|
      @messages[message_type.to_sym] = txt
    end

    room = settings["player_settings"]["room"].downcase.to_sym

    super(room, :player)
  end

  def randomize_start
    super(:player)
  end

  def move(direction)
    possible_directions = {}
    @@map.rooms[@room.color].exits.each do |exit|
      possible_directions[exit.from_direction] = exit.to_room
    end
    if possible_directions.has_key?(direction)
      set_room(possible_directions[direction], :player)
    else
      puts "There is no exit in that direction. Try again."
      return false
    end
    get_loot
    @stats[:moves] += 1
    return true
  end

  def get_loot
    if @@map.rooms[@room.color].has_loot?
      puts "You find another gem and put it in your pocket."
      @inventory[:gems] += @@map.rooms[@room.color].gems
      @@map.rooms[@room.color].gems
      @@map.rooms[@room.color].switch_flag(:loot)
    end
  end

  def look(gems_required)
    sense(gems_required)

    print "\nYou are in the "
    @room.color.to_s.split.each {|word| print word.capitalize + " "} 
    puts "Room. #{@room.description}"

    print "\nExits: "
    (0..(@room.exits.length-2)).each do |x| 
      print @room.exits[x].from_direction.to_s.capitalize + ", "
    end
    puts "and " + @room.exits.last.from_direction.to_s.capitalize + "."
  end

  def sense(gems_required)
    @room.exits.each do |exit|
      case 
      when has_gem_sense? && @@map.rooms[exit.to_room].has_loot?
        puts @messages[:gem].sample + " [A gem is near.]"
      when has_goal_sense? && @@map.rooms[exit.to_room].is_goal?
        if gems_required < @inventory[:gems]
          puts @messages[:goal].sample + " [The goal is near.]"
        end
      when has_grue_sense? && @@map.rooms[exit.to_room].has_grue?
        puts @messages[:grue].sample + " [You are likely to be eaten by a grue.]"
      end
    end
  end

  def see
    puts "\nGrue is in " + Grue.instance.is_in_room.to_s.capitalize
    puts "It's current route is: #{Grue.instance.path.route}"
    print "Goal is in " 
    @@map.rooms.each_value do |room| 
      if room.is_goal?
        puts room.color.to_s.capitalize 
        @path_to_goal = Path.new(@room.color, room.color)
        puts "Path to goal is #{@path_to_goal.route}"
      end
    end
    print "\nGems can be found in:"
    @@map.rooms.each_value do |room| 
      if room.flags[:loot]
        print " " + room.color.to_s.capitalize + " [#{room.gems}]"
      end
    end
    @@map.rooms.each_value do |room|
      puts room.color, room.flags
    end
  end

  def rest(reset)
    @stats[:rest_countdown] = reset
    puts @messages[:rest].sample
  end

  def has_gem_sense? 
    settings[:gem_sense]
  end

  def has_grue_sense? 
    settings[:grue_sense]
  end

  def has_goal_sense? 
    settings[:goal_sense]
  end

  def has_clairvoyance?
    settings[:clairvoyance]
  end
end