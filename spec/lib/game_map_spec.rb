require "spec_helper"
require "game_map"

describe GameMap do
  gm = GameMap.instance
  it "should have rooms with exits" do
    gm.rooms.empty?.should == false
    gm.rooms.each_value do |room|
      room.exits.empty?.should == false
    end
  end
end