class MostImpressiveGuess
  def initialize(wordles)
    @wordles = wordles
  end

  def calculate
    wordle_with_least_hints = find_least_hints
    wordle_with_least_hints.person
  end

  def find_least_hints
    winning_score = @wordles.min_by(&:score).score
    winners = @wordles.select { |wordle| wordle.score == winning_score }
    winners.min_by do |wordle|
      guesses = wordle.guesses[0...-1] # Exclude final correct guess
      guesses.sum(&:weighted_hints)
    end
  end
end
