class MostImpressiveGuess
  def initialize(wordles)
    @wordles = wordles
  end

  def calculate
    winning_score = @wordles.min_by(&:score).score
    winners = @wordles.select { it.score == winning_score }

    min_hints = winners.map do |wordle|
      guesses = wordle.guesses[0...-1] # Exclude final correct guess
      guesses.sum(&:weighted_hints)
    end.min

    winners.select do |wordle|
      guesses = wordle.guesses[0...-1] # Exclude final correct guess
      guesses.sum(&:weighted_hints) == min_hints
    end
  end
end
