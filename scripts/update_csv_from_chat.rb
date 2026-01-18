#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../source/wordle_chat_parser'
require_relative '../source/wordle_csv_parser'
require_relative '../source/wordle_history_updater'

puts "Updating CSV with new wordles from chat.txt..."

# Update history first
puts "Updating wordle history..."
WordleHistoryUpdater.new.update

# Parse existing CSV
csv_parser = WordleCsvParser.new
existing_wordles = csv_parser.parse
puts "Found #{existing_wordles.count} existing entries in CSV"

# Parse chat.txt
puts "Parsing chat.txt..."
chat_wordles = WordleChatParser.new.parse
puts "Found #{chat_wordles.count} wordle entries in chat"

# Create a set of existing wordle keys (person + wordle_number)
existing_keys = existing_wordles.map { |w| "#{w.person}_#{w.wordle_number}" }.to_set

# Find new wordles
new_wordles = chat_wordles.reject do |w|
  existing_keys.include?("#{w.person}_#{w.wordle_number}")
end

if new_wordles.empty?
  puts "No new wordles found. CSV is up to date!"
else
  puts "Found #{new_wordles.count} new wordles to add"

  # Combine and save
  all_wordles = (existing_wordles + new_wordles).sort_by { |w| [w.wordle_number, w.person] }
  csv_parser.save(all_wordles)

  puts "CSV updated successfully!"
  puts "\nNew entries:"
  new_wordles.each do |w|
    puts "  Wordle #{w.wordle_number} - #{w.person} - Score: #{w.score} - Date: #{w.date.strftime('%Y-%m-%d')}"
  end
end

