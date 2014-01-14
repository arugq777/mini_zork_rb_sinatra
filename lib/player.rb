require "./lib/room_occupant"

class Player < RoomOccupant
  attr_accessor :stats, :inventory, :settings, :path_to_goal

  def initialize(room)
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

    #room = settings["player_settings"]["room"].downcase.to_sym
    super(room, :player)
  end

  # def move(direction)
  #   possible_directions = {}
  #   @@map.rooms[@room.color].exits.each do |exit|
  #     possible_directions[exit.from_direction] = exit.to_room
  #   end
  #   if possible_directions.has_key?(direction)
  #     set_room(possible_directions[direction], :player)
  #   else
  #     puts "There is no exit in that direction. Try again."
  #     return false
  #   end
  #   get_loot
  #   @stats[:moves] += 1
  #   return true
  # end

  def move(direction)
    move_msg = ""
    possible_directions = {}
    @@map.rooms[@room.color].exits.each do |exit|
      possible_directions[exit.from_direction] = exit.to_room
    end
    if possible_directions.has_key?(direction)
      set_room(possible_directions[direction], :player)
      move_msg = "You move to the #{direction.to_s.upcase}"
    else
      move_msg = "There is no exit in that direction. Try again."
      return false
    end
    @stats[:moves] += 1
    move_msg
  end

  def get_loot
    if @@map.rooms[@room.color].has_loot?
      @inventory[:gems] += @@map.rooms[@room.color].gems
      @@map.rooms[@room.color].gems
      @@map.rooms[@room.color].switch_flag(:loot)
      msg = "You find another gem and put it in your pocket."
    end
    msg
  end

  def list_exits
    exits = []
    @room.exits.each do |exit|
      exits << exit.from_direction.to_s
    end
    exits
  end

  # def look(gems_required)
  #   sense(gems_required)

  #   print "\nYou are in the "
  #   @room.color.to_s.split.each {|word| print word.capitalize + " "} 
  #   puts "Room. #{@room.description}"

  #   print "\nExits: "
  #   (0..(@room.exits.length-2)).each do |x| 
  #     print @room.exits[x].from_direction.to_s.capitalize + ", "
  #   end
  #   puts "and " + @room.exits.last.from_direction.to_s.capitalize + "."
  # end

  def look
    look_msg = "You are in the "
    @room.color.to_s.split.each {|word| look_msg += word.capitalize + " "} 
    look_msg += "Room. #{@room.description}"
    look_msg
  end

  # def sense(gems_required)
  #   @room.exits.each do |exit|
  #     case 
  #     when has_gem_sense? && @@map.rooms[exit.to_room].has_loot?
  #       puts @messages[:gem].sample + " [A gem is near.]"
  #     when has_goal_sense? && @@map.rooms[exit.to_room].is_goal?
  #       if gems_required < @inventory[:gems]
  #         puts @messages[:goal].sample + " [The goal is near.]"
  #       end
  #     when has_grue_sense? && @@map.rooms[exit.to_room].has_grue?
  #       puts @messages[:grue].sample + " [You are likely to be eaten by a grue.]"
  #     end
  #   end
  # end

  def sense (gems_required)
    sense_msg = []
    @room.exits.each do |exit|
      case 
      when has_gem_sense? && @@map.rooms[exit.to_room].has_loot?
        sense_msg << @messages[:gem].sample + " [A gem is near.]"
      when has_goal_sense? && @@map.rooms[exit.to_room].is_goal?
        if gems_required < @inventory[:gems]
          sense_msg << @messages[:goal].sample + " [The goal is near.]"
        end
      when has_grue_sense? && @@map.rooms[exit.to_room].has_grue?
        sense_msg << @messages[:grue].sample + " [You are likely to be eaten by a grue.]"
      end
    end
    sense_msg
  end

  def see(grue)
    puts "\nGrue is in " + grue.is_in_room.to_s.capitalize
    puts "It's current route is: #{grue.path.route}"
    print "Grue has fled: ", grue.fled_this_turn, "\n"
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
    puts "\n"
    @@map.rooms.each_value do |room|
      print room.color, room.flags, "\n"
    end
  end

  def rest(reset)
    @stats[:rest_countdown] = reset
    @messages[:rest].sample
  end

  def has_gem_sense? 
    @settings[:gem_sense]
  end

  def has_grue_sense? 
    @settings[:grue_sense]
  end

  def has_goal_sense? 
    @settings[:goal_sense]
  end

  def has_clairvoyance?
    @settings[:clairvoyance]
  end
end