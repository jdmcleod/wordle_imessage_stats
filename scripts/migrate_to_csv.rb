#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../source/wordle_chat_parser'
require_relative '../source/wordle_csv_parser'
require_relative '../source/wordle_history_updater'

puts "Starting migration from chat.txt to wordle_results.csv..."

puts "Updating wordle history..."
WordleHistoryUpdater.new.update

puts "Parsing chat.txt..."
wordles = WordleChatParser.new.parse
puts "Found #{wordles.count} wordle entries"

puts "Saving to CSV..."
WordleCsvParser.new.save(wordles)

puts "Migration complete! Created data/wordle_results.csv with #{wordles.count} entries"
puts "\nSample entries:"
wordles.first(3).each do |w|
  puts "  Wordle #{w.wordle_number} - #{w.person} - Score: #{w.score} - Date: #{w.date.strftime('%Y-%m-%d')}"
end

