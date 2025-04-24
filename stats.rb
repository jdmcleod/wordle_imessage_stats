# frozen_string_literal: true

require 'table_tennis'
require_relative 'person_stats'
require_relative 'wordle_chat_parser'

worldes = WordleChatParser.new.parse

grouped = worldes.group_by(&:person)

# grouped.each do |person, wordles|
#   stats = PersonStats.new(person, wordles)
#   stats.print_calculation
# end

stats = grouped.map do |person, wordles|
  stats = PersonStats.new(person, wordles)
  stats.calculate
end.sort_by { _1[:avg] }

options = {
  color_scales: :avg,
  color: true,
  columns: stats.first.keys,
  row_numbers: true,
  title: 'Wordle Stats',
  titleize: true,
  zebra: true,
}

puts TableTennis.new(stats, options)
