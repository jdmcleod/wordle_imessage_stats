require 'date'
require_relative 'contact'
require_relative 'history_manager'
require_relative 'guess'

class Wordle
  REGEXP = /^Wordle \d+/

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

  def guesses
    @guesses ||= data.split("\n").map(&:strip).map { Guess.new(_1) }
  end

  def score_for_average
    return 7 if lost?

    score
  end

  def score
    guesses.length
  end

  def answer
    HistoryManager.instance.answer_for(wordle_number)
  end

  def time_string
    date.strftime("%A, %b %-d at %-I:%M%P")
  end

  def greens_on_first_guess
    guesses.first.greens
  end

  def lost?
    score == 6 && guesses.last.greens != 5
  end

  def greens
    guesses.sum(&:greens)
  end

  def yellows
    guesses.sum(&:yellows)
  end

  def whites
    guesses.sum(&:whites)
  end

  def total_letters
    score * 5
  end

  def first_guess_blank?
    guesses.first.blank?
  end

  def green_errors
    return 0 if guesses.size <= 1

    errors = 0
    guesses.each_cons(2) do |prev_guess, current_guess|
      prev_greens = prev_guess.green_positions
      current_greens = current_guess.green_positions

      errors += (prev_greens - current_greens).size
    end
    errors
  end
end
