class Room
	attr_accessor :color, :adjective, :description, :exits, :flags, :gems

  Exit = Struct.new(:from_room, :from_direction, :to_room, :to_direction)

  def initialize(color, adjective, exit_array, options = {})
    @color = color.downcase.to_sym
    @adjective = adjective
    @exits = exit_array

    @description = options[:description] ||
      "The walls of this room are #{@adjective} #{@color}."

    @flags = {player: false, 
              grue:   false,
              goal:   false, 
              loot:   false,
              valid:  true  }

    @gems = options[:gems] || 0
    @flags[:loot] = @gems > 0
  end

def switch_flag(flag, options = {})
    @flags[flag] = options[:value] || !@flags[flag]
  end

  def is_goal?
    return @flags[:goal]
  end

  def has_grue?
    return @flags[:grue]
  end

  def has_player?
    return @flags[:player]
  end

  def has_loot?
    return @flags[:loot]
  end

  def is_valid?
    return @flags[:valid]
  end

  # finish writing this when you want to mess around with different maps
  #
  # def validate
  #   valid_exits
  #   has_exits?
  #   has_entrances?
  # end
  # def valid_exits
  #   @exits.each do |exit|
  #     unless @valid_directions.include?(exit.to_direction) && 
  #            @valid_directions.include?(exit.from_direction) &&
  #            @rooms.include?(exit.to_room) &&
  #            @rooms.include?(exit.from_room)
  #       exits.delete(exit)
  #       #log info: invalid exit deleted
  #     end
  #   end
  # end
  # def has_exits?
  #   if @exits.empty?
  #     #log error: room has no exits
  #     @flags[:valid] = false
  #   end
  # end
  # def has_entrances?(game_map)
  # end
end