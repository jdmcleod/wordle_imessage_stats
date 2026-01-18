# frozen_string_literal: true

require 'date'
require_relative '../source/wordle_csv_parser'
require_relative '../source/wordle_stats'

def calculate_current_streaks
  yesterday = Date.today - 1
  yesterday_cutoff = Time.new(yesterday.year, yesterday.month, yesterday.day, 23, 59, 0)

  all_wordles = WordleCsvParser.new.parse.reject do |wordle|
    Time.new(wordle.date.year, wordle.date.month, wordle.date.day) > yesterday_cutoff
  end

  grouped = all_wordles.group_by(&:person)

  streaks = grouped.map do |person, wordles|
    sorted_wordles = wordles.sort_by { |w| -w.wordle_number }

    current_streak = 0
    expected_number = sorted_wordles.first.wordle_number

    sorted_wordles.each do |wordle|
      if wordle.wordle_number == expected_number && !wordle.lost?
        current_streak += 1
        expected_number -= 1
      else
        break if wordle.wordle_number < expected_number
        break if wordle.lost?
      end
    end

    { person: person, streak: current_streak }
  end

  streaks.sort_by { |s| -s[:streak] }
end

def print_streaks
  streaks = calculate_current_streaks
  longest_streak = streaks.first

  puts "\n🔥 CURRENT WORDLE STREAKS 🔥\n\n"

  streaks.each_with_index do |stat, index|
    prefix = index == 0 ? "👑 " : "   "
    emoji = stat[:streak] >= 10 ? "🔥" : stat[:streak] >= 5 ? "⚡" : "✓"
    puts "#{prefix}#{stat[:person]}: #{stat[:streak]} #{emoji}"
  end

  puts "\n#{longest_streak[:person]} has the longest current streak at #{longest_streak[:streak]} days! 🎉\n\n"
end

print_streaks

