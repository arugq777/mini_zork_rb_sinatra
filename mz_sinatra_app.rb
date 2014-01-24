require "rubygems"
gem "rubytree", "0.8.3"

require "./lib/mzweb"
require "sinatra"
require "sinatra/partial"

class MiniZorkApp < Sinatra::Base

  set :mzw, MiniZorkWeb.new({})
  
  helpers do
    def reset_mzw(mzw)
      settings.mzw = mzw
    end
    def session_settings=(hash)
      @settings = hash
    end
    def session_settings
      @settings
    end
  end

  get '/' do
    mzw = MiniZorkWeb.new({})
    reset_mzw(mzw)
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
    if params['clicked_command']
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
    else
      session_settings = {}
      #puts "sss1", sess_settings
      session_settings = params
      #puts "sss2", sess_settings
      new_mzw = MiniZorkWeb.new(session_settings)
      reset_mzw(new_mzw)
      erb :main
    end
  end
end

MiniZorkApp.run!