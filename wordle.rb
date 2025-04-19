require 'date'
require_relative 'contact'

class Wordle
  attr_reader :person, :wordle_number, :date, :data

  def initialize(person, wordle_number, date, data)
    @person = Contact.name_for person
    @wordle_number = wordle_number
    @date = date
    @data = data
  end

  def self.parse(index, lines)
    line = lines[index]
    wordle_number = line.gsub(',', '').match(/Wordle (\d+)/)[1]
    date = DateTime.parse(lines[index - 2])
    person = lines[index - 1]
    data = extract_wordle_block_from(lines[index + 2], lines[index + 3..index + 8])
    new(person, wordle_number, date, data)
  end

  def self.extract_wordle_block_from(starting_line, remaining_lines)
    block = [starting_line]

    remaining_lines.each do |line|
      line = line.strip
      break unless line.match?(/^[⬜⬛🟩🟨]+$/)

      block << line
    end

    block.join("\n")
  end

  def parsed_data
    data.split("\n").map(&:strip)
  end

  def score
    parsed_data.length
  end

  def time_string
    date.strftime("%A, %b %-d at %-I:%M%P")
  end

  def greens_on_first_guess
    parsed_data.first.count("🟩")
  end

  def lost?
    score == 6 && parsed_data.last.count('🟩') != 5
  end

  def greens
    parsed_data.sum { _1.count('🟩') }
  end

  def yellows
    parsed_data.sum { _1.count('🟩') }
  end

  def yellows
    parsed_data.sum { _1.count('🟨') }
  end

  def whites
    parsed_data.sum { _1.count('⬜') + _1.count('⬛') }
  end

  def total_letters
    score * 5
  end
end
