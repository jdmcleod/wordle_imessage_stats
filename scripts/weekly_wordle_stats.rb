# frozen_string_literal: true

require_relative '../source/wordle_stats'
require_relative '../source/weekly_stats'

# Create a WordleStats object
stats = WordleStats.new

# Pass the WordleStats object to WeeklyStats
weekly_stats = WeeklyStats.new(stats)

# Print the top impressive guessers for the last 7 days
weekly_stats.print_lowest_average_player
weekly_stats.print_top_impressive_guessers
weekly_stats.print_wordle_scores
