require "rubygems"
gem "rubytree", "0.8.3"

require "./lib/mzweb"
require "sinatra"
require "sinatra/partial"
require "slim"
require "haml"

class MiniZorkApp < Sinatra::Base

  set :template_type, :slim
  set :mzw, MiniZorkWeb.new({})
  
  helpers do
    def reset_mzw(mzw)
      settings.mzw = mzw
    end
    def mzw_get(template)
      method( settings.template_type ).call("/#{settings.template_type}/#{template}".to_sym)
    end
    def session_settings=(hash)
      @settings = hash
    end
    def session_settings
      @settings
    end
    def set_template_type(type)
      if [:erb, :haml, :slim ].include?(type)
        settings.template_type = type
      else
        puts "Invalid template type. How did that even happen?"
      end
    end
  end

  get '/' do
    mzw = MiniZorkWeb.new({})
    reset_mzw(mzw)
    mzw_get( :index )
  end

  get '/exits' do
    mzw_get( :exits )
  end

  get '/info' do
    mzw_get( :info )
  end

  get '/settings' do
    mzw_get( :settings )
  end

  post '/' do
    if params['clicked_command']
      command = params['clicked_command'].to_sym
      unless settings.mzw.game_over
        settings.mzw.play(command)
        if settings.mzw.player.moved? || settings.mzw.player.rested?
          mzw_get( :turn )
        else
          mzw_get( :invalid_move )
        end
      end
    elsif params['template_type']
      type = params['template_type'].to_sym
      set_template_type(type)
      mzw_get( :index )
    else
      session_settings = {}
      session_settings = params
      new_mzw = MiniZorkWeb.new(session_settings)
      reset_mzw(new_mzw)
      mzw_get( :main )
    end
  end
end

MiniZorkApp.run!
