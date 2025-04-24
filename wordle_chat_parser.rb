# frozen_string_literal: true

require_relative 'wordle'

class WordleChatParser
  def parse
    chat = File.read('chat.txt')
    wordle_summaries = []

    lines = chat.split("\n")

    lines.each.with_index do |line, index|
      wordle_summaries << Wordle.parse(index, lines) if line.match?(Wordle::REGEXP)
    end

    wordle_summaries
  end
end
