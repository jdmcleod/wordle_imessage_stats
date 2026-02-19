# frozen_string_literal: true

require 'csv'
require_relative 'wordle'
require_relative 'wordles_csv_parser'

class WordleCsvParser
  CSV_FILE = 'data/wordle_results.csv'

  HEADERS = %w[wordle_number person score is_best_guess is_luckiest_guess guesses_data].freeze

  def parse
    return [] unless File.exist?(CSV_FILE)

    wordles_parser = WordlesCsvParser.new
    wordles_data = wordles_parser.parse.group_by { |w| w[:wordle_number] }

    wordles = []
    CSV.foreach(CSV_FILE, headers: true) do |row|
      wordle_num = row['wordle_number'].to_i
      wordle_info = wordles_data[wordle_num]&.first || {}

      wordles << row_to_wordle(row, wordle_info)
    end
    wordles
  end

  def parse_with_metadata
    return [[], {}] unless File.exist?(CSV_FILE)

    wordles_parser = WordlesCsvParser.new
    wordles_data = wordles_parser.parse.group_by { |w| w[:wordle_number] }

    wordles = []
    metadata = {}

    CSV.foreach(CSV_FILE, headers: true) do |row|
      wordle_num = row['wordle_number'].to_i
      wordle_info = wordles_data[wordle_num]&.first || {}

      wordle = row_to_wordle(row, wordle_info)
      wordles << wordle

      key = "#{row['person']}_#{row['wordle_number']}"
      metadata[key] = {
        nyt_average_score: wordle_info[:nyt_average_score],
        chat_average_score: wordle_info[:chat_average_score],
        is_best_guess: row['is_best_guess'],
        is_luckiest_guess: row['is_luckiest_guess'],
        message_sent: wordle_info[:message_sent]
      }
    end

    [wordles, metadata]
  end

  def save(wordles)
    CSV.open(CSV_FILE, 'w', write_headers: true, headers: HEADERS) do |csv|
      wordles.each do |wordle|
        csv << wordle_to_row(wordle)
      end
    end
  end

  def save_with_metadata(wordles, metadata = {})
    wordles_parser = WordlesCsvParser.new

    # Group wordles by number to extract wordle-level data
    wordles_by_number = {}
    wordles.each do |wordle|
      num = wordle.wordle_number
      unless wordles_by_number[num]
        key = "#{wordle.person}_#{num}"
        meta = metadata[key] || {}

        wordles_by_number[num] = {
          'wordle_number' => num,
          'date' => wordle.date.iso8601,
          'wordle_word' => wordle.answer,
          'nyt_average_score' => meta[:nyt_average_score],
          'chat_average_score' => meta[:chat_average_score],
          'message_sent' => meta[:message_sent]
        }
      end
    end

    # Save wordles table
    wordles_parser.save(wordles_by_number.values)

    # Save results table
    CSV.open(CSV_FILE, 'w', write_headers: true, headers: HEADERS) do |csv|
      wordles.each do |wordle|
        csv << wordle_to_row_with_metadata(wordle, metadata)
      end
    end
  end

  def update_with_metadata(nyt_averages: {}, chat_averages: {}, best_guesses: {}, luckiest_guesses: {}, message_sent: {})
    wordles_parser = WordlesCsvParser.new

    # Update wordles table with wordle-level data
    nyt_averages.each do |wordle_num, score|
      wordles_parser.update_wordle(wordle_num, nyt_average_score: score)
    end

    chat_averages.each do |wordle_num, score|
      wordles_parser.update_wordle(wordle_num, chat_average_score: score)
    end

    message_sent.each do |wordle_num, sent|
      wordles_parser.update_wordle(wordle_num, message_sent: sent)
    end

    # Update results table with person-level data
    rows = CSV.read(CSV_FILE, headers: true)

    updated_rows = rows.map do |row|
      person = row['person']
      wordle_num = row['wordle_number']
      key = "#{wordle_num}_#{person}"

      row['is_best_guess'] = best_guesses[key] ? 'true' : 'false' if best_guesses.key?(key)
      row['is_luckiest_guess'] = luckiest_guesses[key] ? 'true' : 'false' if luckiest_guesses.key?(key)

      row
    end

    CSV.open(CSV_FILE, 'w', write_headers: true, headers: rows.headers) do |csv|
      updated_rows.each do |row|
        csv << row
      end
    end
  end

  def mark_wordle_as_sent(wordle_number)
    WordlesCsvParser.new.mark_wordle_as_sent(wordle_number)
  end

  def get_unsent_wordles_in_range(start_date, end_date)
    WordlesCsvParser.new.get_unsent_wordles_in_range(start_date, end_date)
  end

  private

  def row_to_wordle(row, wordle_info = {})
    Wordle.new(
      row['person'],
      row['wordle_number'],
      wordle_info[:date] || DateTime.now,
      row['guesses_data']
    )
  end

  def wordle_to_row(wordle)
    [
      wordle.wordle_number,
      wordle.person,
      wordle.score,
      nil,
      nil,
      wordle.data
    ]
  end

  def wordle_to_row_with_metadata(wordle, metadata)
    key = "#{wordle.person}_#{wordle.wordle_number}"
    existing_metadata = metadata[key] || {}

    [
      wordle.wordle_number,
      wordle.person,
      wordle.score,
      existing_metadata[:is_best_guess],
      existing_metadata[:is_luckiest_guess],
      wordle.data
    ]
  end
end

