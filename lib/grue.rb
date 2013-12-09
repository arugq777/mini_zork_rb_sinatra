require "singleton"
require "./lib/room_occupant"
require "./lib/game_map"
require "./lib/path"
require "./lib/player"

class Grue < RoomOccupant
  include Singleton
  attr_accessor :path, :messages

  def initialize
    json = File.read("./config/game_config.json")
    settings = JSON.parse(json)

    room = settings["grue_settings"]["room"].downcase.to_sym
    super(room, :grue)
    
    @path = Path.new(@room.color, Player.instance.is_in_room)

    @messages = {}
    settings["grue_settings"]["messages"].each do |key,value|
      @messages[key.downcase.to_sym] = value
    end

  end

  def move
    # if @settings[:session_logs]
    #   unless @path.route[0] == @room
    #     #log "warning: path[0] does not match current room"
    #   end
    #   game_map.rooms[@room].exits.each do |exit|
    #     if exit.to_room == @path.route[1]
    #       #log info: grue moves #{exit.to_direction} from #{exit.from_room} to #{exit.to_room}
    #     end
    #   end
    # end
    set_room(@path.route[1], :grue)
    @path = Path.new(@room.color, Player.instance.is_in_room)
    @path.get_route
  end

  def flee
    @@map.rooms[@room.color].gems += 1
    @@map.rooms[@room.color].switch_flag(:loot, value: true)
    #or maybe something else, like: move; fled_this_turn = true;
    @path.route[1] = @room.exits.sample.to_room
    puts @messages[:flee].sample
  end
end