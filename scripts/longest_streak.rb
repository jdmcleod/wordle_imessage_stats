# frozen_string_literal: true

require 'date'
require_relative '../source/wordle_chat_parser'
require_relative '../source/wordle_stats'

# Calculate the current streak for each person
def calculate_current_streaks
  yesterday = Date.today - 1
  yesterday_cutoff = Time.new(yesterday.year, yesterday.month, yesterday.day, 23, 59, 0)

  all_wordles = WordleChatParser.new.parse.reject do |wordle|
    Time.new(wordle.date.year, wordle.date.month, wordle.date.day) > yesterday_cutoff
  end

  # Group by person
  grouped = all_wordles.group_by(&:person)

  streaks = grouped.map do |person, wordles|
    # Sort by wordle number descending (most recent first)
    sorted_wordles = wordles.sort_by { |w| -w.wordle_number }

    # Calculate current streak
    current_streak = 0
    expected_number = sorted_wordles.first.wordle_number

    sorted_wordles.each do |wordle|
      # Check if this is the expected number and the person didn't lose
      if wordle.wordle_number == expected_number && !wordle.lost?
        current_streak += 1
        expected_number -= 1
      else
        # If they lost or missed a day, streak ends
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

