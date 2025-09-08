class WordleStatsPrinter
  attr_reader :stats, :wordle

  def initialize(stats, wordle)
    @stats = stats
    @wordle = wordle
  end

  def print
    puts to_s
  end

  def to_s
    lines = []
    lines << "⏰ #{relative_date}'s Wordle (#{wordle.wordle_number}, #{wordle.answer}) was harder than #{difficulty_percentile}% of all #{stats.total} chat Wordles"
    lines << "🎯Chat averaged #{wordle.average_score} (NYT average of #{worldwide_average})"
    lines << attempts
    lines << "🔥Best guess -> #{wordle.most_impressive_guess.map(&:to_player_string_with_score).join(' and ')}"
    lines.join("\n")
  end

  private

  def relative_date
    if wordle.date.day == Date.today.day
      'Today'
    elsif wordle.date.day == (Date.today - 1).day
      'Yesterday'
    else
      wordle.date.strftime('%b %d')
    end
  end

  def difficulty_percentile
    wordle_index = stats.sorted_wordles.index { _1.wordle_number == wordle.wordle_number }
    ((wordle_index.to_f / stats.total.to_f) * 100.0).round
  end

  def worldwide_average
    WordleAverageWebScraper.new.parse(wordle.wordle_number)
  end

  def attempts
    chat_completions = stats.wordles.select { _1.wordle_number == wordle.wordle_number }.count
    completion_percentage = (chat_completions.to_f / stats.number_of_players.to_f * 100).round
    green_squares = (completion_percentage / 20.0).round
    squares = '⬜' * 5
    squares[0...green_squares] = '🟩' * green_squares if green_squares.positive?

    "#{squares} #{chat_completions}/#{stats.number_of_players} attempts"
  end
end
