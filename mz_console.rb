mz = MiniZork.new

until mz.game_over
  mz.output_for_this_turn
  print mz.settings[:prompt]
  input = gets.chomp.to_sym
  mz.play(input)
end
mz.output_for_this_turn