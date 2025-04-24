# frozen_string_literal: true

require_relative 'wordle_chat_parser'

worldes = WordleChatParser.new.parse

grouped = worldes.group_by(&:answer)

total = grouped.count

by_difficulty = grouped.map do |answer, wordles|
  average_score = (wordles.sum(&:score_for_average) / wordles.count.to_f).round(2)
  [answer, average_score, wordles.first.date.strftime('%b %d %Y')]
end

sorted = by_difficulty.sort_by { _1[1] }
formatted = sorted.map.with_index { "#{total - _2}. #{_1.join(', ')}" }

puts "#{formatted.length} wordles"

puts formatted
