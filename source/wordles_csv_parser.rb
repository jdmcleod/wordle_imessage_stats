# frozen_string_literal: true

require 'csv'

class WordlesCsvParser
  CSV_FILE = 'data/wordles.csv'

  HEADERS = %w[wordle_number date wordle_word nyt_average_score chat_average_score message_sent].freeze

  def parse
    return [] unless File.exist?(CSV_FILE)

    wordles = []
    CSV.foreach(CSV_FILE, headers: true) do |row|
      wordles << row_to_hash(row)
    end
    wordles
  end

  def find_by_number(wordle_number)
    return nil unless File.exist?(CSV_FILE)

    CSV.foreach(CSV_FILE, headers: true) do |row|
      return row_to_hash(row) if row['wordle_number'] == wordle_number.to_s
    end
    nil
  end

  def update_wordle(wordle_number, updates = {})
    return unless File.exist?(CSV_FILE)

    rows = CSV.read(CSV_FILE, headers: true)

    updated_rows = rows.map do |row|
      if row['wordle_number'] == wordle_number.to_s
        updates.each do |key, value|
          row[key.to_s] = value
        end
      end
      row
    end

    CSV.open(CSV_FILE, 'w', write_headers: true, headers: rows.headers) do |csv|
      updated_rows.each do |row|
        csv << row
      end
    end
  end

  def mark_wordle_as_sent(wordle_number)
    update_wordle(wordle_number, message_sent: 'true')
  end

  def get_unsent_wordles_in_range(start_date, end_date)
    return [] unless File.exist?(CSV_FILE)

    unsent_wordles = []
    CSV.foreach(CSV_FILE, headers: true) do |row|
      next if row['message_sent'] == 'true'

      date = DateTime.parse(row['date'])
      if date >= start_date && date < end_date
        unsent_wordles << {
          wordle_number: row['wordle_number'].to_i,
          date: date
        }
      end
    end

    unsent_wordles.sort_by { |w| w[:date] }.map { |w| w[:wordle_number] }
  end

  def save(wordles_data)
    CSV.open(CSV_FILE, 'w', write_headers: true, headers: HEADERS) do |csv|
      wordles_data.each do |wordle|
        csv << wordle_to_row(wordle)
      end
    end
  end

  def upsert_wordle(wordle_data)
    return unless File.exist?(CSV_FILE)

    rows = CSV.read(CSV_FILE, headers: true)
    wordle_num = wordle_data['wordle_number'].to_s

    existing_index = rows.find_index { |r| r['wordle_number'] == wordle_num }

    if existing_index
      wordle_data.each do |key, value|
        rows[existing_index][key.to_s] = value if value
      end
    else
      new_row = CSV::Row.new(HEADERS, [])
      wordle_data.each do |key, value|
        new_row[key.to_s] = value
      end
      rows << new_row
    end

    CSV.open(CSV_FILE, 'w', write_headers: true, headers: HEADERS) do |csv|
      rows.each { |row| csv << row }
    end
  end

  private

  def row_to_hash(row)
    {
      wordle_number: row['wordle_number'].to_i,
      date: DateTime.parse(row['date']),
      wordle_word: row['wordle_word'],
      nyt_average_score: row['nyt_average_score']&.to_f,
      chat_average_score: row['chat_average_score']&.to_f,
      message_sent: row['message_sent'] == 'true'
    }
  end

  def wordle_to_row(wordle)
    [
      wordle[:wordle_number] || wordle['wordle_number'],
      wordle[:date] || wordle['date'],
      wordle[:wordle_word] || wordle['wordle_word'],
      wordle[:nyt_average_score] || wordle['nyt_average_score'],
      wordle[:chat_average_score] || wordle['chat_average_score'],
      wordle[:message_sent] || wordle['message_sent']
    ]
  end
end

