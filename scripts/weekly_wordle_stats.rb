# frozen_string_literal: true

require_relative '../source/wordle_stats'
require_relative '../source/weekly_stats'

stats = WordleStats.new

weekly_stats = WeeklyStats.new(stats)

weekly_stats.print_lowest_average_player
weekly_stats.print_top_impressive_guessers
weekly_stats.print_wordle_scores
