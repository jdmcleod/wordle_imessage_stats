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
end
