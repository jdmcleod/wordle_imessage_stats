class WordleStatistic
  attr_reader :answer, :average_score, :date, :wordle_number, :most_impressive_guess

  def initialize(answer:, average_score:, date:, wordle_number:, most_impressive_guess:)
    @answer = answer
    @average_score = average_score
    @date = date
    @wordle_number = wordle_number
    @most_impressive_guess = most_impressive_guess
  end

  def most_impressive_guesser
    if most_impressive_guess.is_a?(Array)
      most_impressive_guess.map(&:person).join(' and ')
    else
      most_impressive_guess.person
    end
  end

  def to_s
    [
      answer,
      average_score,
      date.strftime('%b %d %Y'),
      wordle_number
    ].join(', ')
  end
end
