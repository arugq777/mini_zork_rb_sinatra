require "./lib/minizork"

class MiniZorkWeb < MiniZork
  def initialize(session_settings)
    @game_over = false
    @quit = false

    import_settings_from_json
    import_map_from_json

    #set map class variables for Path, Grue and Player
    Path.set_map(@map)
    RoomOccupant.set_map(@map)

    process_session_settings(session_settings)
    
    additional_map_settings

    start_room = initialize_starting_positions
    @player = Player.new(start_room[:player], @all_settings[:player])
    @grue = Grue.new(start_room[:grue], start_room[:player], @all_settings[:grue])
    starting_output
  end
  
  def process_session_settings(session_settings)
    game_boolean = [:random_gems, :randomize_player_start, :randomize_grue_start, :randomize_goal] 
    player_boolean = [:gem_sense, :goal_sense, :grue_sense, :clairvoyance]
    numbers = [:turns_between_rest, :random_gem_chance, :gems_required]
    symbols = [:player_room, :grue_room, :goal_room]
    new_hash = {}

    (game_boolean + player_boolean + numbers + symbols).each do |k|
      new_hash[k] = nil
    end
    #puts "nh", new_hash
    unless session_settings.empty?
      #puts "ss", session_settings
      session_settings.each_key do |key|
        new_hash[key.to_sym] = session_settings[key]
      end

      (player_boolean + game_boolean).each do |key|
        if new_hash[key].nil?
          new_hash[key] = false
        else
          new_hash[key] = true
        end
      end

      numbers.each do |key|
        new_hash[key] = new_hash[key].to_i unless new_hash[key].nil?
      end

      symbols.each do |key|
        new_hash[key] = new_hash[key].to_sym unless new_hash[key].nil?
      end

      new_hash.each_key do |key|
        if player_boolean.include?( key )
          @all_settings[:player][:settings][key] = new_hash[key]
        elsif game_boolean.include?( key )
          @all_settings[:game][key] = new_hash[key]
        elsif numbers.include?( key )
          @all_settings[:game][key] = new_hash[key]
        elsif symbols.include?( key )
          k = []
          key.to_s.split('_').each {|s| k << s.to_sym}
          @all_settings[k[0]][k[1]] = new_hash[key]
        else
          puts "nothing happened."
        end
      end
      # puts "nh2", new_hash
      # puts "as", @all_settings
    end
  end
end