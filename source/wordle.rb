require 'date'
require_relative 'contact'
require_relative 'history_manager'
require_relative 'guess'

class Wordle
  attr_reader :person, :wordle_number, :date, :data

  def initialize(person, wordle_number, date, data)
    @person = Contact.name_for person
    @wordle_number = wordle_number.to_i
    @date = date
    @data = data
  end

  def guesses
    @guesses ||= data.split("\n").map(&:strip).map { Guess.new(_1) }
  end

  def to_player_string_with_score
    percent_revealed = (information_score.to_f / 3 * 20).round
    "#{person} (in #{score} with #{percent_revealed}% information)"
  end

  def to_player_string_with_luck
    parts = []
    parts << "#{greens_on_first_guess}G" if greens_on_first_guess > 0
    parts << "#{yellows_on_first_guess}Y" if yellows_on_first_guess > 0
    "#{person} (#{parts.join(', ')})"
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

  def yellows_on_first_guess
    guesses.first.yellows
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

  ##
  # Greens count as 3 but only once per column and yellows count as 1
  def information_score
    relevant_guesses = guesses[0...-1] # Exclude the last and correct guess
    combined_columns = relevant_guesses.map(&:in_array).transpose

    score_for_each_column = combined_columns.map do |column|
      next 3 if column.include?(Guess::GREEN)
      next column.count(Guess::YELLOW) if column.include?(Guess::YELLOW) # multiple yellows in one column count as one each
      0 # no greens or yellows
    end

    score_for_each_column.sum
  end
end
