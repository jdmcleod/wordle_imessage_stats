require 'date'
require_relative 'contact'
require_relative 'history_manager'
require_relative 'guess'

class Wordle
  attr_reader :person, :wordle_number, :date, :data

  def initialize(person, wordle_number, date, data)
    @person = Contact.name_for person
    @wordle_number = wordle_number
    @date = date
    @data = data
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
    score == 6 && guesses.last.correct
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

  def first_guess_luck
    guesses.first.luck
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
