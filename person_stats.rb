class PersonStats
  attr_reader :person, :wordles

  def initialize(person, wordles)
    @person = person
    @wordles = wordles
  end

  def calculate
    puts "Stats for #{person}:"
    puts "Total Wordles: #{wordles.count}"
    print_scores
    print_average
    print_greens_on_first_guess
    print_percent_green
    print_percent_yellows
    print_no_yellows
    print_blank_first_guesses
    print_average_time
    puts ''
  end

  def print_scores
    print 'Scores:'
    wordles.group_by(&:score).sort_by { _1 }.each do |score, wordles|
      print "|#{score}:#{wordles.count}|"
    end
    print_losses
    puts ''
  end

  def print_average
    avg = average(wordles.sum(&:score_for_average), wordles.count)
    puts "Average score: #{avg}"
  end

  def print_greens_on_first_guess
    number = wordles.sum(&:greens_on_first_guess)

    puts "Average greens on first guess: #{average(number, wordles.count)}"
  end

  def average(number, total)
    (number.to_f / total).round(2)
  end

  def print_average_time
    avg = average(wordles.map(&:date).sum(&:hour), wordles.count)
    formatted_time = format_hour(avg)
    puts "Average hour submitted: #{formatted_time}"
  end

  def format_hour(decimal_hour)
    hour, decimal = decimal_hour.to_s.split('.').map(&:to_i)
    meridian = hour >= 12 ? 'PM' : 'AM'
    percent_through_hour = ((decimal / 100.to_f) * 60).round
    hour = 12 if hour == 0
    hour = hour % 12 if hour > 12
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

  def print_no_yellows
    puts "No yellows: #{wordles.count { |w| w.yellows.zero? }}"
  end

  def print_blank_first_guesses
    puts "Blank first guesses: #{wordles.count(&:first_guess_blank?)}"
  end
end
