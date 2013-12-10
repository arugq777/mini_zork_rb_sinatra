require "./lib/game_map"
class RoomOccupant
  attr_accessor :room

  def initialize(room, flag, options = {})
    @@map = GameMap.instance
    @room = @@map.rooms[room]
    @@map.rooms[room].switch_flag(flag)
  end

  def is_in_room
    return @room.color
  end

  def set_room(new_room_color, flag_id)
    @@map.rooms[@room.color].switch_flag(flag_id)
    @@map.rooms[new_room_color].switch_flag(flag_id)
    @room = @@map.rooms[new_room_color]
  end

  def randomize_start(flag_id)
    @@map.rooms.each_value {|room| room.flags[flag_id] = false}
    set_room(@@map.rooms.keys.sample, flag_id)
    if @room.has_grue? && @room.has_player?
      @room.switch_flag(flag_id)
      randomize_start()
    end
  end
end