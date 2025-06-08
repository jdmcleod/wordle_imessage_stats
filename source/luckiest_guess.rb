class LuckiestGuess
  def initialize(wordles)
    @wordles = wordles
  end

  def calculate
    max_luck_amount = @wordles.max_by(&:first_guess_luck).first_guess_luck
    @wordles
      .select { it.first_guess_luck == max_luck_amount }
      .map(&:to_player_string_with_luck)
  end
end
