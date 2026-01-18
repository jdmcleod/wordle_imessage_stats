#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../source/wordle_chat_parser'
require_relative '../source/wordle_csv_parser'
require_relative '../source/wordle_history_updater'

puts "Updating CSV with new wordles from chat.txt..."

puts "Updating wordle history..."
WordleHistoryUpdater.new.update

csv_parser = WordleCsvParser.new
existing_wordles, existing_metadata = csv_parser.parse_with_metadata
puts "Found #{existing_wordles.count} existing entries in CSV"

puts "Parsing chat.txt..."
chat_wordles = WordleChatParser.new.parse
puts "Found #{chat_wordles.count} wordle entries in chat"

existing_keys = existing_wordles.map { |w| "#{w.person}_#{w.wordle_number}" }.to_set

new_wordles = chat_wordles.reject do |w|
  existing_keys.include?("#{w.person}_#{w.wordle_number}")
end

if new_wordles.empty?
  puts "No new wordles found. CSV is up to date!"
else
  puts "Found #{new_wordles.count} new wordles to add"

  all_wordles = (existing_wordles + new_wordles).sort_by { |w| [w.wordle_number, w.person] }

  csv_parser.save_with_metadata(all_wordles, existing_metadata)

  puts "CSV updated successfully!"
  puts "\nNew entries added:"
  new_wordles.each do |w|
    puts "  Wordle #{w.wordle_number} - #{w.person} - Score: #{w.score} - Date: #{w.date.strftime('%Y-%m-%d')}"
  end
end

