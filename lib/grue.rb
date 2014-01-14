#require "singleton"
require "./lib/room_occupant"
require "./lib/game_map"
require "./lib/path"
require "./lib/player"

class Grue < RoomOccupant

  attr_accessor :path, :messages, :fled_this_turn

  def initialize(start, destination)
    json = File.read("./config/game_config.json")
    settings = JSON.parse(json)

    super(start, :grue)
    
    @path = Path.new(@room.color, destination)

    @messages = {}
    settings["grue_settings"]["messages"].each do |key,value|
      @messages[key.downcase.to_sym] = value
    end

  end

  def move(destination)
    set_room(@path.route[1], :grue)
    @path = Path.new(@room.color, destination)
    @path.get_route
    msg = "[grue moves to #{@room.color}. Current route: #{@path.route}]"
    msg
  end

  def flee(player)
    @@map.rooms[@room.color].gems += 1
    @@map.rooms[@room.color].switch_flag(:loot, value: true)

    until @path.route[1] != player.room.color
      @path.route[1] = @room.exits.sample.to_room
    end
    
    move(@path.route[1])
    @fled_this_turn = true
    @messages[:flee].sample
  end
end