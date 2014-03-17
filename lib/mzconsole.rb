require "./lib/minizork"

class MiniZorkConsole < MiniZork

  @@info = [:gems, :i, :inventory, :stats, :statistics, :moves, 
            :turns, :l, :look]
  @@output_order = [:move, :grue_flees, :loot, :rest, :turn, :start, 
                    :look, :sense, :exits, :grue_move, :lose, :win]
  @@info_order = [:turns, :moves, :inventory, :rest_countdown]
  @@clairvoyance= [:grue, :grue_path, :goal, :goal_path, :loot]

  def initialize
    super
  end

  def format_info_for_console
    update_info_hash
    @info_hash[:messages] = {}
    @info_hash[:messages][:inventory] = "\nYou have #{@info_hash[:player][:inventory][:gems].to_s} gems"
    @info_hash[:messages][:moves] = "\nYou've made #{@info_hash[:player][:moves].to_s} moves in #{@info_hash[:player][:turns].to_s} turns"
    @info_hash[:messages][:stats] = ["\nTurn #{@info_hash[:player][:turns].to_s}",
      "Turns til rest: #{@info_hash[:player][:rest_countdown]}",
      "You have #{@info_hash[:player][:inventory][:gems].to_s} gems out of #{@game_settings[:gems_required]}",
      "You have moved #{@info_hash[:player][:moves].to_s} times\n\n"]
    @info_hash[:messages][:look] = @player.look
    @info_hash[:messages][:exits] = "\nExits: "
    exits = @player.list_exits
    exits.each do |x| 
      @info_hash[:messages][:exits] += "#{x.to_s.upcase} "
    end
  end

  def get_info(command)
    format_info_for_console
    case command
    when :gems, :i, :inventory
      puts @info_hash[:messages][:inventory]
    when :moves, :turns
      puts @info_hash[:messages][:moves]
    when :stats, :statistics
      @info_hash[:messages][:stats].each {|s| puts s}
    when :l, :look
      puts @output_hash[:turn], 
           @info_hash[:messages][:look], 
           @info_hash[:messages][:exits]
    end
  end

  def play(command)
    @grue.fled_this_turn = false
    unless @game_over
      @output_hash = {}
      @output_hash[:look] = @player.look
      #@output_hash[:sense] = @player.sense(@settings[:gems_required])
      if time_to_rest?
        rest #duh.
        end_turn
      elsif @@info.include?(command)
        get_info(command)
      else          
        execute_command(command)
        if @output_hash[:move] == false
          puts "There is no exit to the #{command.to_s.upcase}!"
        else
          end_turn
        end
      end
    end
    return @output_hash
  end

  def print_output(print_order, hash_to_print)
    print_order.each do |key|
      unless hash_to_print[key].nil?
        if key == :exits
          print "Exits: "
          hash_to_print[key].each do |array_string|
            print "#{array_string.upcase} "
          end
          puts "\n\n"
        elsif hash_to_print[key].is_a?(Hash) && !hash_to_print[key].empty?
          print "[#{key.to_s}]: "
          hash_to_print[key].each do |key2, string|
            puts "[#{key2.to_s}]: #{string}"
          end
          puts ""
        else
          puts "[#{key.to_s}]: #{hash_to_print[key]}"
        end
      end
    end    
  end

  def output_for_this_turn
    print_output(@@info_order, @info_hash[:player])
    print_output(@@clairvoyance, @info_hash[:clairvoyance])
    print_output(@@output_order, @output_hash)
  end
end
