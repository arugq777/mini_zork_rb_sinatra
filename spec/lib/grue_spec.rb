require "spec_helper"
require "grue"
require "player"

describe Grue do
  json = File.read("./config/game_config.json")
  settings = JSON.parse(json, symbolize_names: true)

  json = File.read("./config/map_config.json")
  map = GameMap.new(json)

  Path.set_map(map)
  RoomOccupant.set_map(map)

  g = Grue.new(:cobalt, :emerald, settings[:grue])
  p = Player.new(:emerald, settings[:player])

  it "has a room" do
    g.room.should_not == nil
    map.rooms[g.room.color].should_not == nil
  end

  it "has a path" do
    g.path.should_not == nil
  end

  it "moves" do
    room1 = g.room
    g.move(:emerald)
    room2 = g.room
    room1.should_not == room2
  end

  it "moves along path" do
    path1 = g.path
    g.move(:emerald)
    path1.route[1].should == g.path.route[0]
  end

  it "updates path after moving" do
    path1 = g.path
    g.move(:emerald)
    g.path.should_not == path1
  end

  it "moves toward player" do
    g.path.route.last.should == p.room.color
  end
end