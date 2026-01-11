class Guess
  attr_reader :data

  GREEN = "🟩"
  YELLOW = "🟨"
  WHITE = "⬜"
  BLACK = "⬛"

  def initialize(data)
    @data = data
  end

  def green_positions
    indices = []
    data.split('').each_with_index do |chart, index|
      indices << index if chart == GREEN
    end
    indices
  end

  def greens
    data.count GREEN
  end

  def yellows
    data.count YELLOW
  end

  def whites
    data.count(WHITE) + data.count(BLACK)
  end

  def blank?
    data.chars.all?('⬜') || data.chars.all?('⬛')
  end

  def in_array
    data.chars
  end

  def luck
    (greens * 2) + yellows
  end

  def correct?
    greens == 5
  end

  def incorrect?
    !correct?
  end

  def weighted_hints
    (greens * 2) + yellows
  end
end
