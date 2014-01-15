require "./lib/game_map"
class RoomOccupant
  attr_accessor :room

  def initialize(room, flag, options = {})
    @room = @@map.rooms[room]
    @@map.rooms[room].switch_flag(flag)
  end

  def self.set_map(map)
    @@map = map
  end

  def is_in_room
    return @room.color
  end

  def set_room(new_room_color, flag_id)
    @@map.rooms[@room.color].switch_flag(flag_id)
    @@map.rooms[new_room_color].switch_flag(flag_id)
    @room = @@map.rooms[new_room_color]
  end
  
end