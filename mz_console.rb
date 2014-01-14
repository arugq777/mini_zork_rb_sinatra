require "rubygems"
gem 'rubytree',"0.8.3"
require "./lib/minizork"

mz = MiniZork.new

until mz.game_over
  mz.output_for_this_turn
  print mz.settings[:prompt]
  input = gets.chomp.to_sym
  mz.play(input)
end

if mz.quit
  puts "QUITTING."
else
  mz.output_for_this_turn
end