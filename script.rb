# frozen_string_literal: true

chat = File.read('chat.txt')

require_relative 'wordle'
require_relative 'person_stats'

wordle_summaries = []

lines = chat.split("\n")

lines.each.with_index do |line, index|
  wordle_summaries << Wordle.parse(index, lines) if line.match?(Wordle::REGEXP)
end

grouped = wordle_summaries.group_by(&:person)

grouped.each do |person, wordles|
  stats = PersonStats.new(person, wordles)
  stats.calculate
end
