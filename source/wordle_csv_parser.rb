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

  def save(wordles)
    CSV.open(CSV_FILE, 'w', write_headers: true, headers: HEADERS) do |csv|
      wordles.each do |wordle|
        csv << wordle_to_row(wordle)
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
      nil, # nyt_average_score - will be filled later
      nil, # chat_average_score - will be filled later
      nil, # is_best_guess - will be filled later
      nil, # is_luckiest_guess - will be filled later
      wordle.data
    ]
  end
end

