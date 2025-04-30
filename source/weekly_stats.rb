require 'date'

class WeeklyStats
  def initialize(wordle_stats)
    @wordles = wordle_stats.wordles
    @grouped_wordles = wordle_stats.grouped_wordles
  end

  def wordles_within_last_seven_days
    @grouped_wordles.select do |stat|
      stat.date >= (Date.today - 7)
    end
  end

  def top_impressive_guessers
    last_seven_days_wordles = wordles_within_last_seven_days

    top_guesser = last_seven_days_wordles
                  .group_by(&:most_impressive_guesser)
                  .max_by { |_, wordles| wordles.count }

    top_guesser
  end

  def print_top_impressive_guessers
    top_guesser = top_impressive_guessers

    if top_guesser
      puts "\nPlayer(s) with the most impressive guesses in the last 7 days: #{top_guesser[0].join(', ')} (#{top_guesser[1].count} times)"
    else
      puts "\nNo data available for impressive guesses in the last 7 days."
    end
  end

  def lowest_average_in_last_seven
    person_stats = @wordles.group_by(&:person).map do |person, person_wordles|
      last_seven_wordles = person_wordles.sort_by(&:date).last(7)
      average_score = calculate_average_score(last_seven_wordles)
      { person: person, average_score: average_score, wordles_count: last_seven_wordles.size }
    end

    # Select players who played at least 7 Wordles
    eligible_players = person_stats.select { |stat| stat[:wordles_count] == 7 }
    eligible_players.min_by { |stat| stat[:average_score] }
  end

  def print_lowest_average_player
    result = lowest_average_in_last_seven

    if result
      puts "\nPlayer with the lowest average score in their last 7 Wordles: #{result[:person]} (Average Score: #{result[:average_score]})"
    else
      puts "\nNot enough players with at least 7 recent Wordles to calculate lowest average scores."
    end
  end

  private

  def calculate_average_score(wordles)
    return 0 if wordles.empty?

    (wordles.sum(&:score_for_average) / wordles.count.to_f).round(2)
  end
end
