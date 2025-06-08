# frozen_string_literal: true

require 'table_tennis'
require_relative '../source/person_stats'
require_relative '../source/wordle_chat_parser'
require_relative '../source/wordle_stats'


def print_from_date(cutoff_date = Date.today - 1000, table_name = 'Wordle Stats')

  all_worldes = WordleChatParser
                  .new
                  .parse
                  .reject { it.date < cutoff_date }

  grouped = all_worldes.group_by(&:person)

  stats = grouped.map do |person, person_wordles|
    stats = PersonStats.new(person, person_wordles, all_worldes)
    stats.calculate
  end.sort_by { _1[:avg] }

  options = {
    color_scales: {
      avg: :gyr,
      '2': :b,
      '3': :b,
      '4': :b,
      '5': :b,
      '6': :b,
      'X': :b,
      best_guess: :g,
      gFirst: :g,
      blank: :y,
      errors: :r
    },
    color: true,
    columns: stats.first.keys,
    title: table_name,
    titleize: true,
    zebra: true,
  }

  puts TableTennis.new(stats, options)
end

print_from_date(Date.today - 7, 'Weekly stats')
print_from_date(Date.today - 30, 'Monthly stats')
print_from_date(Date.today - 1000, 'All time stats')
