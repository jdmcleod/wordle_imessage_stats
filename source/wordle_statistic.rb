class WordleStatistic
  attr_reader :answer, :average_score, :date, :wordle_number,
              :luckiest_guesser, :most_impressive_guesser

  def initialize(answer:, average_score:, date:, wordle_number:,
                 luckiest_guesser:, most_impressive_guesser:)
    @answer = answer
    @average_score = average_score
    @date = date
    @wordle_number = wordle_number
    @luckiest_guesser = luckiest_guesser
    @most_impressive_guesser = most_impressive_guesser
  end

  def most_impressive_guessers
    if most_impressive_guesser.is_a?(Array)
      most_impressive_guesser.join(' and ')
    else
      most_impressive_guesser
    end
  end

  def luckiest_guessers
    if luckiest_guesser.is_a?(Array)
      luckiest_guesser.join(' and ')
    else
      luckiest_guesser
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
