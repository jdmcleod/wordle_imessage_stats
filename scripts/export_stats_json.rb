require 'json'
require 'date'
require 'active_support/core_ext/date'
require_relative '../source/wordle_chat_parser'
require_relative '../source/wordle_stats'

# ...existing code in stats.rb assumed...

# Example: stats.rb exposes a Stats class with .all returning an array of user stats
# Each user stat has a name and an array of games with date and score

# Adjust the following block to match your actual stats.rb API
# users = Stats.all # => [#<UserStat name="Alice" games=[{date: "2024-06-01", score: 3}, ...]>, ...]

all_wordles = WordleChatParser.new.parse
month_wordles = all_wordles.reject { it.date < Date.new(2025, 8, 1) }

grouped = month_wordles.group_by(&:person)
all_grouped = all_wordles.group_by(&:person)

output = grouped.map do |name, wordles|
  {
    name:,
    scores: wordles.map { { date: it.date, score: it.score } }
  }
end

# Export daily stats
File.open('data/wordle_stats.json', 'w') do |f|
  f.write(JSON.pretty_generate(output))
end

# Export weekly averages
weekly_output = all_grouped.map do |name, wordles|
  grouped_by_week = wordles.group_by { |w| w.date.beginning_of_week(:monday).to_date }
  weekly_scores = grouped_by_week.map do |week_start, week_wordles|
    avg_score = week_wordles.sum(&:score).to_f / week_wordles.size.to_f
    { date: week_start, score: avg_score.round(2) }
  end.sort_by { |entry| entry[:date] }

  {
    name:,
    scores: weekly_scores
  }
end

File.open('data/wordle_stats_weekly.json', 'w') do |f|
  f.write(JSON.pretty_generate(weekly_output))
end

puts "Exported stats to data/wordle_stats.json"
puts "Exported weekly averages to data/wordle_stats_weekly.json"
