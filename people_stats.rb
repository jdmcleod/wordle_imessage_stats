# frozen_string_literal: true

require_relative 'person_stats'

require_relative 'wordle_chat_parser'

worldes = WordleChatParser.new.parse

grouped = worldes.group_by(&:person)

grouped.each do |person, wordles|
  stats = PersonStats.new(person, wordles)
  stats.calculate
end
