require "rubygems"
gem "rubytree", "0.8.3"

require "./lib/mzweb"
require "sinatra"
require "sinatra/partial"
require "haml"

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
    # erb :"/erb/index"
    haml :"/haml/index"
  end

  get '/exits' do
    # erb :"/erb/exits"
    haml :"/haml/exits"
  end

  get '/info' do
    # erb :"/erb/info"
    haml :"/haml/info"

  end

  get '/settings' do
    # erb :"/erb/settings"
    haml :"/haml/settings"
  end

  post '/' do
    if params['clicked_command']
      command = params['clicked_command'].to_sym
      unless settings.mzw.game_over
        settings.mzw.play(command)
        if settings.mzw.output_hash[:move] == false
          @msg = "There is no exit to the #{command.to_s.upcase}!"
          # erb :"/erb/invalid_move", locals: {msg: @msg}
          haml :"/haml/invalid_move", locals: {msg: @msg}
        else
          # erb :"/erb/turn"
          haml :"/haml/turn"
        end
      end
    else
      session_settings = {}
      #puts "sss1", sess_settings
      session_settings = params
      #puts "sss2", sess_settings
      new_mzw = MiniZorkWeb.new(session_settings)
      reset_mzw(new_mzw)
      # erb :"/erb/main"
      haml :"/haml/main"
    end
  end
end

MiniZorkApp.run!
