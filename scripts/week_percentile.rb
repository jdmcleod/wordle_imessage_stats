require 'date'
require_relative '../source/wordle_stats'

def week_start_date(date)
  date.to_date - date.to_date.wday
end

def calculate_weekly_averages(wordles)
  wordles
    .group_by { |w| week_start_date(w.date) }
    .map do |week_start, week_wordles|
      scores = week_wordles.map(&:score_for_average)
      average = (scores.sum / scores.size.to_f).round(2)
      {
        week_start: week_start,
        average: average,
        count: scores.size
      }
    end
    .sort_by { |w| w[:week_start] }
end

def current_week_start
  today = Date.today
  today - today.wday
end

def calculate_percentile(value, all_values)
  return 0 if all_values.empty?

  count_below = all_values.count { |v| v < value }
  ((count_below.to_f / all_values.size) * 100).round(1)
end

stats = WordleStats.new
wordles = stats.wordles

weekly_averages = calculate_weekly_averages(wordles)

if weekly_averages.empty?
  puts "No wordle data available."
  exit
end

trailing_week_date = Date.today - 7
trailing_week_start = week_start_date(trailing_week_date)
current_week = weekly_averages.find { |w| w[:week_start] == trailing_week_start } || weekly_averages.last
is_current_week = false

all_averages = weekly_averages.map { |w| w[:average] }

percentile = calculate_percentile(current_week[:average], all_averages)

current_week_end = current_week[:week_start] + 6

puts "Week: #{current_week[:week_start].strftime('%b %-d')} - #{current_week_end.strftime('%b %-d, %Y')}"
puts "Chat Average: #{current_week[:average]} (#{percentile}%)"

if is_current_week && Date.today.wday > 0
  puts "(Note: Week in progress - statistics may change)"
end

if percentile < 25
  puts "Performance: Excellent! (Top 25%)"
elsif percentile < 50
  puts "Performance: Good (Top 50%)"
elsif percentile < 75
  puts "Performance: Average (Top 75%)"
else
  puts "Performance: Below Average"
end

# puts "\nHistorical Context:"
# puts "Total Weeks Analyzed: #{weekly_averages.size}"
# puts "Best Week Ever: #{all_averages.min}"
# puts "Worst Week Ever: #{all_averages.max}"
# puts "Overall Average: #{(all_averages.sum / all_averages.size.to_f).round(2)}"

if weekly_averages.size >= 5
  puts "\nRecent Weeks:"
  weekly_averages.last(5).each do |week|
    week_end = week[:week_start] + 6
    marker = week == current_week ? " <- Trailing" : ""
    percentile_rank = calculate_percentile(week[:average], all_averages)
    puts "  #{week[:week_start].strftime('%b %-d')} - #{week_end.strftime('%b %-d')}: #{week[:average]} (#{week[:count]} games, #{percentile_rank}% percentile)#{marker}"
  end
end
