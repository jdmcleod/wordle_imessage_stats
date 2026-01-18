# frozen_string_literal: true

require 'table_tennis'
require_relative '../source/person_stats'
require_relative '../source/wordle_csv_parser'
require_relative '../source/wordle_stats'
require_relative '../source/month_winner_table'

def stats_table_options(columns, title)
  {
    color_scales: { avg: :gyr, '1': :b, '2': :b, '3': :b, '4': :b, '5': :b, '6': :b, 'X': :b, best_guess: :g },
    color: true,
    columns:,
    title:,
    titleize: true,
    zebra: true,
  }
end

def print_from_date(cutoff_date = Date.today - 1000, table_name = 'Wordle Stats', punish_misses: false)
  yesterday = Date.today - 1
  yesterday_cutoff = Time.new(yesterday.year, yesterday.month, yesterday.day, 23, 59, 0)
  all_worldes = WordleCsvParser.new.parse.reject do |wordle|
    wordle.date.to_date < cutoff_date || Time.new(wordle.date.year, wordle.date.month, wordle.date.day) > yesterday_cutoff
  end

  grouped = all_worldes.group_by(&:person)

  stats = grouped.map do |person, person_wordles|
    stats = PersonStats.new(person, person_wordles, all_worldes, punish_misses:)
    stats.calculate
  end.sort_by { _1[:avg] }

  puts TableTennis.new(stats, stats_table_options(stats.first.keys, table_name))
end

print_from_date(Date.today - 7, 'Weekly stats', punish_misses: true)
print_from_date(Date.today - 1000, 'All time stats')
MonthWinnerTable.print
