# frozen_string_literal: true

require 'table_tennis'
require_relative '../source/person_stats'
require_relative '../source/wordle_chat_parser'
require_relative '../source/wordle_stats'
require_relative '../source/month_winner_table'

def stats_table_options(columns, title)
  {
    color_scales: { avg: :gyr, '1': :b, '2': :b, '3': :b, '4': :b, '5': :b, '6': :b, 'X': :b, best_guess: :g, gFirst: :g, errors: :r },
    color: true,
    columns:,
    title:,
    titleize: true,
    zebra: true,
  }
end

def print_from_date(cutoff_date = Date.today - 1000, table_name = 'Wordle Stats')
  all_worldes = WordleChatParser.new.parse.reject { it.date < cutoff_date || it.date > (Date.today - 1) }

  grouped = all_worldes.group_by(&:person)

  stats = grouped.map do |person, person_wordles|
    stats = PersonStats.new(person, person_wordles, all_worldes)
    stats.calculate
  end.sort_by { _1[:avg] }

  puts TableTennis.new(stats, stats_table_options(stats.first.keys, table_name))
end

print_from_date(Date.today - 8, 'Weekly stats')
print_from_date(Date.today - 1000, 'All time stats')
MonthWinnerTable.print
