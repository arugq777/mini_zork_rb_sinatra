require "spec_helper"
require "player"

describe Player do
  p = Player.instance
  it "should be in a room" do
    p.room.should_not == nil
    p.room.should be_a(Room)
    p.room.color.should be_a(Symbol)
    p.room.exits.should be_an(Array)
    p.room.exits.empty?.should == false
    p.room.exits[0].should be_a(Room::Exit)
    GameMap.instance.rooms[p.room.color].should_not == nil
  end

  
end