require 'json'
require_relative '../source/wordle_chat_parser'
require_relative '../source/wordle_stats'

# ...existing code in stats.rb assumed...

# Example: stats.rb exposes a Stats class with .all returning an array of user stats
# Each user stat has a name and an array of games with date and score

# Adjust the following block to match your actual stats.rb API
# users = Stats.all # => [#<UserStat name="Alice" games=[{date: "2024-06-01", score: 3}, ...]>, ...]

all_worldes = WordleChatParser.new.parse.reject { it.date < Date.new(2025, 8, 1) }

grouped = all_worldes.group_by(&:person)

output = grouped.map do |name, wordles|
  {
    name:,
    scores: wordles.map { { date: it.date, score: it.score } }
  }
end

File.open('wordle_stats.json', 'w') do |f|
  f.write(JSON.pretty_generate(output))
end

puts "Exported stats to wordle_stats.json"

