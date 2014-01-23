require "./lib/room_occupant"

class Player < RoomOccupant
  attr_accessor :stats, :inventory, :settings, :path_to_goal

  def initialize(room, settings)
    
    @stats = {alive: true, turns: 1, moves: 0, rest_countdown: -1}

    @stats[:rest_countdown] += settings[:stats][:rest_countdown]
    @settings  = settings[:settings]
    @inventory = settings[:inventory]
    @messages  = settings[:messages]

    super(room, :player)
  end


  def move(direction)
    move_msg = "You move to the "
    possible_directions = {}
    @@map.rooms[@room.color].exits.each do |exit|
      possible_directions[exit.from_direction] = exit.to_room
    end
    if possible_directions.has_key?(direction)
      set_room(possible_directions[direction], :player)
      move_msg += "#{direction.to_s.upcase}"
    else
      # return false to prevent end_turn.
      # I suppose there could be more methods like
      # player.moved_this_turn? or player.rested_this_turn?
      # then I could replace this 'return false' with 
      # 'move_msg = "There is no exit to the #{direction.to_s.upcase}"'
      # Maybe later.
      return false
    end
    @stats[:moves] += 1
    move_msg
  end

  def get_loot
    if @@map.rooms[@room.color].has_loot?
      @inventory[:gems] += @@map.rooms[@room.color].gems
      @@map.rooms[@room.color].gems = 0
      @@map.rooms[@room.color].switch_flag(:loot)
      loot_msg = "You find another GEM and put it in your pocket."
    end
    loot_msg
  end

  def list_exits
    exits_array = []
    @room.exits.each do |exit|
      exits_array << exit.from_direction.to_s
    end
    exits_array
  end

  def look
    look_msg = "You are in the "
    @room.color.to_s.split.each {|word| look_msg += word.capitalize + " "} 
    look_msg += "Room. #{@room.description}"
    if @room.is_goal?
      look_msg += "\nThere is a box in this room, connected to a large apparatus. The apparatus itself is indiscerible in the darkness, but the box has conveniently GEM-shaped slots."
    end
    look_msg
  end

  def sense (gems_required, grue)
    sense_msg = {}
    #check for stuff from player's position
    @room.exits.each do |exit|
      case 
      when has_gem_sense? && @@map.rooms[exit.to_room].has_loot?
        sense_msg[:gem] = @messages[:gem].sample + " [A GEM is near.]"
      when has_goal_sense? && @@map.rooms[exit.to_room].is_goal?
        if gems_required <= @inventory[:gems]
          sense_msg[:goal] = @messages[:goal].sample + " [The GOAL is near.]"
        end
      when has_grue_sense? && @@map.rooms[exit.to_room].has_grue?
        sense_msg[:grue] = @messages[:grue].sample + " [The GRUE is near.]"
      end
    end
    #since corridors are one way, have grue_sense check proximity from grue's position
    if has_grue_sense?
      grue.room.exits.each do |exit|
        if @@map.rooms[exit.to_room].has_player?
          sense_msg[:grue_likely] = "You are likely to be eaten by a GRUE."
        end
      end
    end
    sense_msg unless sense_msg.empty?
  end

  #this is used in the console version's look command;
  #could probably delete this.
  def see(grue)
    puts "GRUE is in " + grue.is_in_room.to_s.capitalize
    puts "It's current route is: #{grue.path.route}"
    print "GRUE has fled: ", grue.fled_this_turn, "\n"
    print "GOAL is in " 
    @@map.rooms.each_value do |room| 
      if room.is_goal?
        puts room.color.to_s.capitalize 
        @path_to_goal = Path.new(@room.color, room.color)
        puts "Path to GOAL is #{@path_to_goal.route}"
      end
    end
    print "\nGEMS can be found in:"
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