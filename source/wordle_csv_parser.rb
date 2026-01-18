# frozen_string_literal: true

require 'csv'
require_relative 'wordle'

class WordleCsvParser
  CSV_FILE = 'data/wordle_results.csv'

  HEADERS = [
    'wordle_number',
    'date',
    'person',
    'wordle_word',
    'score',
    'nyt_average_score',
    'chat_average_score',
    'is_best_guess',
    'is_luckiest_guess',
    'guesses_data'
  ].freeze

  def parse
    return [] unless File.exist?(CSV_FILE)

    wordles = []
    CSV.foreach(CSV_FILE, headers: true) do |row|
      wordles << row_to_wordle(row)
    end
    wordles
  end

  def parse_with_metadata
    return [[], {}] unless File.exist?(CSV_FILE)

    wordles = []
    metadata = {}

    CSV.foreach(CSV_FILE, headers: true) do |row|
      wordle = row_to_wordle(row)
      wordles << wordle

      key = "#{row['person']}_#{row['wordle_number']}"
      metadata[key] = {
        nyt_average_score: row['nyt_average_score'],
        chat_average_score: row['chat_average_score'],
        is_best_guess: row['is_best_guess'],
        is_luckiest_guess: row['is_luckiest_guess']
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
    CSV.open(CSV_FILE, 'w', write_headers: true, headers: HEADERS) do |csv|
      wordles.each do |wordle|
        csv << wordle_to_row_with_metadata(wordle, metadata)
      end
    end
  end

  def update_with_metadata(nyt_averages: {}, chat_averages: {}, best_guesses: {}, luckiest_guesses: {})
    rows = CSV.read(CSV_FILE, headers: true)

    updated_rows = rows.map do |row|
      wordle_num = row['wordle_number']
      person = row['person']
      key = "#{wordle_num}_#{person}"

      row['nyt_average_score'] = nyt_averages[wordle_num] if nyt_averages[wordle_num]
      row['chat_average_score'] = chat_averages[wordle_num] if chat_averages[wordle_num]
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

  private

  def row_to_wordle(row)
    Wordle.new(
      row['person'],
      row['wordle_number'],
      DateTime.parse(row['date']),
      row['guesses_data']
    )
  end

  def wordle_to_row(wordle)
    [
      wordle.wordle_number,
      wordle.date.iso8601,
      wordle.person,
      wordle.answer,
      wordle.score,
      nil,
      nil,
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
      wordle.date.iso8601,
      wordle.person,
      wordle.answer,
      wordle.score,
      existing_metadata[:nyt_average_score],
      existing_metadata[:chat_average_score],
      existing_metadata[:is_best_guess],
      existing_metadata[:is_luckiest_guess],
      wordle.data
    ]
  end
end

