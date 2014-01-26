require "rubygems"
gem "rubytree", "0.8.3"
require "./lib/mzconsole"

mz = MiniZorkConsole.new

until mz.game_over
  mz.output_for_this_turn #if mz.player.moved_this_turn?
  print mz.game_settings[:prompt]
  input = gets.chomp.to_sym
  mz.play(input)
end

if mz.quit
  puts "QUITTING."
else
  mz.output_for_this_turn
end
