class MostImpressiveGuess
  def initialize(wordles)
    @wordles = wordles
  end

  def calculate
    winning_score = @wordles.min_by(&:score).score
    winners = @wordles.select { it.score == winning_score }
    min_information = winners.map(&:information_score).min

    winners.select do |wordle|
      min_information == wordle.information_score
    end
  end
end
