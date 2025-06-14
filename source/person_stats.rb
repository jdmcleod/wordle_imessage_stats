class PersonStats
  attr_reader :person, :wordles, :all_wordles

  def initialize(person, wordles, all_worldes)
    @person = person
    @wordles = wordles
    @all_wordles = all_worldes
  end

  def print_calculate
    puts "Stats for #{person}:"
    puts "Total Wordles: #{wordles.count}"
    print_scores
    print_average
    print_greens_on_first_guess
    print_percent_green
    print_percent_yellows
    print_no_yellows
    print_blank_first_guesses
    print_errors
    print_average_time
    puts ''
  end

  def calculate
    {
      name: person,
      total: wordles.count,
      avg: average,
      # one: wordles.count { it.score == 1 },
      '2': wordles.count { it.score == 2 },
      '3': wordles.count { it.score == 3 },
      '4': wordles.count { it.score == 4 },
      '5': wordles.count { it.score == 5 },
      '6': wordles.count { it.score == 6 },
      'X': wordles.count(&:lost?),
      best_guess: impressive_guesses,
      gFirst: greens_on_first_guess,
      # nYel: no_yellows,
      blank: blank_first_guesses,
      errors: errors,
      avgTime: average_time,
    }
  end

  def impressive_guesses
    WordleStats.new(all_wordles).impressive_guesses_for(person)
  end

  def print_scores
    print 'Scores:'
    wordles.group_by(&:score).sort_by { _1 }.each do |score, wordles|
      print "|#{score}:#{wordles.count}|"
    end
    print_losses
    puts ''
  end

  def average
    calc_average(wordles.sum(&:score_for_average), wordles.count)
  end

  def print_average
    puts "Average score: #{average}"
  end

  def greens_on_first_guess
    number = wordles.sum(&:greens_on_first_guess)
    calc_average(number, wordles.count)
  end

  def print_greens_on_first_guess
    puts "Average greens on first guess: #{greens_on_first_guess}"
  end

  def calc_average(number, total)
    (number.to_f / total).round(2)
  end

  def average_time
    avg = calc_average(wordles.map(&:date).sum(&:hour), wordles.count)
    format_hour(avg)
  end

  def print_average_time
    puts "Average hour submitted: #{average_time}"
  end

  def format_hour(decimal_hour)
    hour, decimal = decimal_hour.to_s.split('.').map(&:to_i)
    meridian = hour >= 12 ? 'PM' : 'AM'
    percent_through_hour = ((decimal / 100.to_f) * 60).round
    hour = 12 if hour == 0
    hour = hour % 12 if hour > 12
    percent_through_hour = percent_through_hour.to_s.prepend('1') if percent_through_hour.digits.count == 1

    "#{hour}:#{percent_through_hour} #{meridian}"
  end

  def print_number_of_twos
    puts "Number of twos: #{wordles.count { |w| w.score == 2 }}"
  end

  def print_losses
    print "X:#{wordles.count(&:lost?)}|"
  end

  def print_percent_green
    percent_green = ((wordles.sum(&:greens).to_f / wordles.sum(&:total_letters)).to_f * 100.to_f).round(2)

    puts "Percent greens: #{percent_green}"
  end

  def print_percent_yellows
    percent_yellow = ((wordles.sum(&:yellows).to_f / wordles.sum(&:total_letters)).to_f * 100.to_f).round(2)

    puts "Percent yellows: #{percent_yellow}"
  end

  def no_yellows
    wordles.count { |w| w.yellows.zero? }
  end

  def print_no_yellows
    puts "No yellows: #{no_yellows}"
  end

  def blank_first_guesses
    wordles.count(&:first_guess_blank?)
  end

  def print_blank_first_guesses
    puts "Blank first guesses: #{blank_first_guesses}"
  end

  def errors
    wordles.sum(&:green_errors)
  end

  def print_errors
    puts "Errors: #{errors}"
  end
end
