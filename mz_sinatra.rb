require "rubygems"
gem "rubytree", "0.8.3"

require "./lib/minizork"
require "sinatra"
require "sinatra/partial"

class MiniZorkWeb < MiniZork
  #created in case any code needed specifially for the 
  #web version, though that apparenty hasn't been necessary
  def initialize(session_settings)
    @game_over = false
    @quit = false

    import_settings_from_json
    import_map_from_json
    parse_session_settings(session_settings)

    #set map class variables for Path, Grue and Player
    Path.set_map(@map)
    RoomOccupant.set_map(@map)

    @map.random_gems(@game_settings[:random_gem_chance]) if @game_settings[:random_gems]
    start_room = initialize_starting_positions
    @player = Player.new(start_room[:player], @all_settings[:player])
    @grue = Grue.new(start_room[:grue], start_room[:player], @all_settings[:grue])
    starting_output
  end
  def parse_session_settings(session_settings)
    unless session_settings.empty?
      new_hash = {}
      game_boolean = [:random_gems, :randomize_player_start, :randomize_grue_start, :randomize_goal] 
      player_boolean = [:gem_sense, :goal_sense, :grue_sense, :clairvoyance]
      numbers = [:turns_between_rest, :random_gem_chance, :gems_required]
      symbols = [:player_room, :grue_room, :goal_room]

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
      # puts new_hash
      # puts @all_settings
    end
  end
end

class MiniZorkApp < Sinatra::Base

  set :session_settings, {}
  set :mzw, MiniZorkWeb.new(settings.session_settings)
  
  helpers do
    def reset
      settings.mzw = MiniZorkWeb.new(settings.session_settings)
    end
  end

  get '/' do
    reset
    erb :index
  end

  get '/exits' do
    erb :exits, :layout => false
  end

  get '/info' do
    erb :info
  end

  get '/settings' do
    erb :settings
  end

  post '/' do
    command = params['clicked_command'].to_sym
    unless settings.mzw.game_over
      settings.mzw.play(command)
      if settings.mzw.output_hash[:move] == false
        @msg = "There is no exit to the #{command.to_s.upcase}!"
        erb :invalid_move, locals: {msg: @msg}
      else
        erb :turn
      end
    end
  end

  post '/settings' do
    settings.session_settings = params
    # puts params
    reset
    erb :main
  end
end

MiniZorkApp.run!