require "spec_helper"
require "player"

describe Player do
  json = File.read("./config/game_config.json")
  settings = JSON.parse(json, symbolize_names: true)

  json = File.read("./config/map_config.json")
  map = GameMap.new(json)

  Path.set_map(map)
  RoomOccupant.set_map(map)

  p = Player.new(:emerald, settings[:player])

  it "should be in a room" do
    p.room.should_not == nil
    p.room.should be_a(Room)
    p.room.color.should be_a(Symbol)
    p.room.exits.should be_an(Array)
    p.room.exits.empty?.should == false
    p.room.exits[0].should be_a(Room::Exit)
    map.rooms[p.room.color].should_not == nil
  end

  it "should be able to move in a valid direction" do
    p.move(:north).should == "There is no exit to the NORTH"
    p.move(:west ).should == "You move to the WEST"
    p.room.color.should == :cobalt
    p.room.color.should_not == nil
    p.room.color.should_not == :emerald
  end
end