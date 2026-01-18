require 'csv'

class HistoryManager
  private_class_method :new

  @instance = nil
  @data = {}

  class << self
    def instance
      @instance ||= new
      @instance
    end

    def reset
      @instance = nil
      @data = {}
    end
  end

  def initialize
    load_history
  end

  def find_by_number(wordle_number)
    self.class.instance
    @@data[wordle_number.to_s]
  end

  def answer_for(wordle_number)
    result = find_by_number(wordle_number)
    result ? result[:answer] : nil
  end

  private

  def load_history
    @@data = {}

    CSV.foreach(File.join('data/history.csv')) do |row|
      date, number, answer = row
      @@data[number] = {
        date: date,
        number: number,
        answer: answer
      }
    end
  end
end
