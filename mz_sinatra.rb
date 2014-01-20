require "rubygems"
gem "rubytree", "0.8.3"

require "./lib/minizork"
require "sinatra"
require "sinatra/partial"

class MiniZorkWeb < MiniZork
  #created in case any code needed specifially for the 
  #web version, though that apparenty hasn't been necessary
  def initialize
    super
  end
end

class MiniZorkApp < Sinatra::Base

  set :mzw, MiniZorkWeb.new    
  
  helpers do
    def reset
      settings.mzw = MiniZorkWeb.new
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

  # get '/settings' do

  # end

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

  # post '/settings' do

  # end
end

MiniZorkApp.run!