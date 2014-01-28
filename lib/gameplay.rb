module Gameplay
  def execute_command(command)
    if @map.valid_directions.include?(command)
      move( command )
      @output_hash[:loot] = @player.get_loot
      if @player.room.is_goal? && victory_conditions_met?
        you_win
      end
    # elsif @@info.include?(command)
    #   get_info(command)
    elsif command == :rest
      rest
    elsif command == :quit
      @game_over = true
      @quit = true
    else
      puts "invalid command: #{command}"
    end
  end

  def update_info_hash
    @info_hash, loot, grue_path, goal_path = {},{},{},{} 
    @info_hash[:player] = @player.stats
    #I'll turn this into a seperate hash if I decide to expand inventory options.
    @info_hash[:player][:inventory] = @player.inventory
    if @player.has_clairvoyance?
      path = Path.new(@player.room.color, @map.goal)
      goal_path[:msg] = "Path to GOAL: "
      goal_path[:list] = path.route      
      grue_path[:msg] = "Current path: "
      grue_path[:list] = @grue.path.route
      loot[:msg] = "GEMS can be found in: "
      loot[:list] = []
      @map.rooms.each_value do |room| 
        if room.flags[:loot]
          loot[:list] << room.color.to_s.capitalize + " [#{room.gems}] "
        end
      end
      @info_hash[:clairvoyance] = {
        grue: "GRUE is in #{@grue.room.color.to_s.upcase}",
        grue_path: grue_path,
        goal: "GOAL is in #{@map.goal.to_s.upcase}",
        goal_path: goal_path,
        loot: loot
      } 
    end
    @info_hash
  end

  def move(direction)
    @output_hash[:move] = @player.move(direction)
    if @player.moved? && @player.room.has_grue?
      @output_hash[:grue_flees] = @grue.flee(player)
      if @player.has_clairvoyance?
        @output_hash[:grue_flees] += "[grue flees to #{@grue.room.color}. Current route: #{@grue.path.route}"
      end
    end
  end

  def rest
    @output_hash[:rest] =  @player.rest(@game_settings[:turns_between_rest])
    @output_hash[:rest] += " [You REST for one turn.]"
  end

  def you_lose
    @output_hash[:lose] =  @messages[:lose1].sample + @messages[:lose2].sample
    @output_hash[:lose] += " [YOU LOSE.]"
    @game_over = true
    #@player.stats[:alive] = false
  end

  def you_win
    @output_hash[:win] =  @messages[:win].sample
    @output_hash[:win] += " [YOU WIN!]"
    @game_over = true
  end

  def time_to_rest?
    @player.stats[:rest_countdown] == 0
  end

  def new_game?
    @player.stats[:turns] == 1
  end

  def victory_conditions_met?
    @player.inventory[:gems] >= @game_settings[:gems_required]
  end

  def play(command)
    @grue.fled_this_turn = false
    @player.stats[:moved_this_turn] = false
    @player.stats[:rested_this_turn] = false
    unless @game_over
      @output_hash = {}
      @output_hash[:look] = @player.look
      if time_to_rest?
        rest #duh.
        end_turn
      else 
        execute_command(command)
        if @player.moved? || @player.rested?
          end_turn
        end
      end
    end
    return @output_hash
  end

  def end_turn
    @player.stats[:turns] += 1
    @player.stats[:rest_countdown] -= 1
    @output_hash[:turn] = "Turn #{@player.stats[:turns]}"
    @output_hash[:look] = @player.look
    @output_hash[:exits] = @player.list_exits
    unless @grue.fled_this_turn
      @output_hash[:grue_move] = @grue.move(@player.room.color)
      you_lose if @grue.room.has_player?
    end
    @output_hash[:sense] = @player.sense(@game_settings[:gems_required], @grue)
    update_info_hash
  end
end
