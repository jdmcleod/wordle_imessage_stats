# frozen_string_literal: true

require 'json'
require 'csv'
require_relative '../source/wordle_stats'
require_relative '../source/wordle_average_web_scraper'
require_relative '../source/wordle_csv_parser'


def fetch_and_update_nyt_averages
  puts "Loading wordle data from CSV..."
  csv_file = WordleCsvParser::CSV_FILE

  csv_data = CSV.read(csv_file, headers: true)
  puts "Found #{csv_data.count} entries in CSV"

  wordles_by_number = csv_data.group_by { |row| row['wordle_number'] }
  unique_wordles = wordles_by_number.keys.sort

  puts "Found #{unique_wordles.count} unique wordles"

  cache_file = 'data/wordle_averages_cache.json'
  nyt_cache = File.exist?(cache_file) ? JSON.parse(File.read(cache_file)) : {}

  missing_nyt_data = []
  csv_data.each do |row|
    if row['nyt_average_score'].nil? || row['nyt_average_score'].strip.empty?
      missing_nyt_data << row['wordle_number']
    end
  end
  missing_nyt_data = missing_nyt_data.uniq.sort

  puts "#{missing_nyt_data.count} wordles missing NYT average in CSV"

  if missing_nyt_data.any?
    puts "\nFetching NYT averages from web..."
    scraper = WordleAverageWebScraper.new
    fetched = 0

    missing_nyt_data.each_with_index do |wordle_number, index|
      cached_value = nyt_cache[wordle_number.to_s]
      if cached_value
        puts "[#{index + 1}/#{missing_nyt_data.count}] Wordle #{wordle_number}: #{cached_value} (cached)"
        fetched += 1
        next
      end

      print "[#{index + 1}/#{missing_nyt_data.count}] Fetching Wordle #{wordle_number}... "
      nyt_avg = scraper.parse(wordle_number.to_i)

      if nyt_avg
        puts "#{nyt_avg}"
        nyt_cache[wordle_number.to_s] = nyt_avg
        fetched += 1
      else
        puts "not available"
      end

      sleep(0.5) if index < missing_nyt_data.count - 1
    end

    puts "\nFetched #{fetched} NYT averages"
  end

  puts "\nUpdating CSV with NYT averages and chat averages..."
  updated_rows = []

  csv_data.each do |row|
    wordle_number = row['wordle_number']

    nyt_avg = nyt_cache[wordle_number.to_s]
    row['nyt_average_score'] = nyt_avg if nyt_avg

    wordle_entries = wordles_by_number[wordle_number]
    if wordle_entries && wordle_entries.count > 0
      scores = wordle_entries.map { |e| e['score'].to_i }
      chat_avg = (scores.sum.to_f / scores.count).round(2)
      row['chat_average_score'] = chat_avg
    end

    updated_rows << row
  end

  CSV.open(csv_file, 'w', write_headers: true, headers: csv_data.headers) do |csv|
    updated_rows.each do |row|
      csv << row
    end
  end

  puts "✓ CSV updated with NYT and chat averages"

  nyt_cache
end

def compare_chat_vs_nyt
  puts "\n" + "=" * 60
  puts "CHAT vs NYT COMPARISON"
  puts "=" * 60 + "\n"

  stats = WordleStats.new
  cache_file = 'data/wordle_averages_cache.json'
  nyt_cache = File.exist?(cache_file) ? JSON.parse(File.read(cache_file)) : {}

  chat_wins = 0
  nyt_wins = 0
  ties = 0
  missing_data = 0

  stats.stats.each do |wordle_stat|
    chat_avg = wordle_stat.average_score
    nyt_avg = nyt_cache[wordle_stat.wordle_number.to_s]&.to_f

    if nyt_avg.nil?
      missing_data += 1
      next
    end

    if chat_avg < nyt_avg
      chat_wins += 1
    elsif chat_avg > nyt_avg
      nyt_wins += 1
    else
      ties += 1
    end
  end

  total_compared = chat_wins + nyt_wins + ties

  puts "Results:"
  puts "=" * 60
  puts "🏆 Chat beat NYT:     #{chat_wins} times (#{(chat_wins.to_f / total_compared * 100).round(1)}%)"
  puts "😔 NYT beat Chat:     #{nyt_wins} times (#{(nyt_wins.to_f / total_compared * 100).round(1)}%)"
  puts "🤝 Tied:              #{ties} times (#{(ties.to_f / total_compared * 100).round(1)}%)"
  puts "=" * 60
  puts "Total compared:       #{total_compared}"
  puts "Missing NYT data:     #{missing_data}"
  puts "Total Wordles:        #{stats.stats.count}"
  puts ""
end

fetch_and_update_nyt_averages
compare_chat_vs_nyt

