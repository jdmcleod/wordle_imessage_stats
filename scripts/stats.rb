# frozen_string_literal: true

require 'table_tennis'
require_relative '../source/person_stats'
require_relative '../source/wordle_chat_parser'

worldes = WordleChatParser.new.parse

grouped = worldes
  .reject { it.date < Date.new(2025, 4, 11) }
  .group_by(&:person)

stats = grouped.map do |person, wordles|
  stats = PersonStats.new(person, wordles)
  stats.calculate
end.sort_by { _1[:avg] }

options = {
  color_scales: { avg: :gyr, two: :b, threes: :b, gFirst: :g, nYel: :b, blank: :y, errors: :r },
  color: true,
  columns: stats.first.keys,
  title: 'Wordle Stats',
  titleize: true,
  zebra: true,
}

puts TableTennis.new(stats, options)
