# frozen_string_literal: true

require 'csv'
require 'date'
require_relative 'wordle_chat_parser'


begin
  first_line = CSV.read('history.csv').first
  unless first_line && Date.parse(first_line[0]) == Date.today
    require_relative 'wordle_history_updater'
    WordleHistoryUpdater.new.update
  end
end

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
