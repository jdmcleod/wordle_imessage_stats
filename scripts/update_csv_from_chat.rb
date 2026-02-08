#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../source/wordle_chat_parser'
require_relative '../source/wordle_csv_parser'
require_relative '../source/wordle_history_updater'
require_relative '../source/wordle_average_web_scraper'
require_relative '../source/most_impressive_guess'
require 'json'

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

def calculate_metadata(all_wordles, new_wordles, existing_metadata)
  updated_metadata = existing_metadata.dup

  cache_file = 'data/wordle_averages_cache.json'
  nyt_cache = File.exist?(cache_file) ? JSON.parse(File.read(cache_file)) : {}

  new_wordle_numbers = new_wordles.map(&:wordle_number).uniq
  missing_nyt_data = new_wordle_numbers.reject { |num| nyt_cache[num.to_s] }

  if missing_nyt_data.any?
    puts "Fetching NYT averages for #{missing_nyt_data.count} new wordles..."
    scraper = WordleAverageWebScraper.new

    missing_nyt_data.each_with_index do |wordle_number, index|
      print "[#{index + 1}/#{missing_nyt_data.count}] Fetching Wordle #{wordle_number}... "
      nyt_avg = scraper.parse(wordle_number)

      if nyt_avg
        puts "#{nyt_avg}"
        nyt_cache[wordle_number.to_s] = nyt_avg
      else
        puts "not available"
      end

      sleep(0.5) if index < missing_nyt_data.count - 1
    end
  end

  wordles_by_number = all_wordles.group_by(&:wordle_number)

  wordles_by_number.each do |wordle_number, wordles|
    nyt_avg = nyt_cache[wordle_number.to_s]

    scores = wordles.map(&:score_for_average)
    chat_avg = scores.any? ? (scores.sum.to_f / scores.count).round(2) : nil

    best_wordles = MostImpressiveGuess.new(wordles).calculate

    wordles.each do |wordle|
      key = "#{wordle.person}_#{wordle.wordle_number}"

      updated_metadata[key] ||= {}
      updated_metadata[key][:nyt_average_score] = nyt_avg
      updated_metadata[key][:chat_average_score] = chat_avg
      updated_metadata[key][:is_best_guess] = best_wordles.include?(wordle).to_s
    end
  end

  updated_metadata
end

if new_wordles.empty?
  puts "No new wordles found. CSV is up to date!"
else
  puts "Found #{new_wordles.count} new wordles to add"

  all_wordles = (existing_wordles + new_wordles).sort_by { |w| [w.wordle_number, w.person] }
  updated_metadata = calculate_metadata(all_wordles, new_wordles, existing_metadata)
  csv_parser.save_with_metadata(all_wordles, updated_metadata)

  puts "CSV updated successfully!"
end

