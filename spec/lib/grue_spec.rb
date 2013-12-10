require "spec_helper"
require "grue"

describe Grue do
  g = Grue.instance

  it "has a room" do
    g.room.should_not == nil
    GameMap.instance.rooms[g.room.color].should_not == nil
  end

  it "has a path" do
    g.path.should_not == nil
  end

  it "moves" do
    room1 = g.room
    g.move
    room2 = g.room
    room1.should_not == room2
  end

  it "moves along path" do
    path1 = g.path
    g.move
    path1.route[1].should == g.path.route[0]
  end

  it "updates path after moving" do
    path1 = g.path
    g.move
    g.path.should_not == path1
  end

  it "moves toward player" do
    g.path.route.last.should == Player.instance.room.color
  end
end