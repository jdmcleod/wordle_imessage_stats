# frozen_string_literal: true

require_relative 'wordle_stats'

stats = WordleStats.new
today_wordle = stats.recent

puts "\n⏰ Today's word (#{today_wordle.answer}) was harder than #{stats.recent_difficulty_percentile}% of all #{stats.total} chat Wordles"
puts "👉Chat averaged #{today_wordle.average_score} (NYT average of #{stats.worldwide_average})"
puts "🔥Today's most impressive guess was from #{today_wordle.most_impressive_guessers}"
puts "👏Today's luckiest first guess was #{today_wordle.luckiest_guessers}\n\n"
