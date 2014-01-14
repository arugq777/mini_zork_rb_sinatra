require "spec_helper"
require "player"

describe Player do
  p = Player.new(:emerald)
  it "should be in a room" do
    p.room.should_not == nil
    p.room.should be_a(Room)
    p.room.color.should be_a(Symbol)
    p.room.exits.should be_an(Array)
    p.room.exits.empty?.should == false
    p.room.exits[0].should be_a(Room::Exit)
    GameMap.instance.rooms[p.room.color].should_not == nil
  end

  it "should be able to move in a valid direction" do
    p.move(:north).should == false
    p.move(:west ).should == true
    p.room.color.should == :cobalt
    p.room.color.should_not == nil
    p.room.color.should_not == :emerald
  end
end