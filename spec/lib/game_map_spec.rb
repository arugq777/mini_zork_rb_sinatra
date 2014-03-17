require "spec_helper"
require "game_map"

describe GameMap do
  json = File.read("./config/map_config.json")
  gm = GameMap.new(json)
  it "should have rooms with exits" do
    gm.rooms.empty?.should == false
    gm.rooms.each_value do |room|
      room.exits.empty?.should == false
    end
  end
end