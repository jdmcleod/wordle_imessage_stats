# frozen_string_literal: true

require_relative 'wordle'

class WordleChatParser
  REGEXP = /^Wordle \d+/

  def parse
    chat = File.read('data/chat.txt')
    wordle_summaries = []

    lines = chat.split("\n")

    lines.each.with_index do |line, index|
      wordle_summaries << parse_line(index, lines) if line.match?(REGEXP) && !lines[index - 1].match(/This message was deleted/)
    end

    wordle_summaries
  end

  private

  def parse_line(index, lines)
    line = lines[index]
    wordle_number = line.gsub(',', '').match(/Wordle (\d+)/)[1]
    date = DateTime.parse(lines[index - 2])
    person = lines[index - 1]
    data = extract_wordle_block_from(lines[index + 2], lines[index + 3..index + 8])

    Wordle.new(person, wordle_number, date, data)
  end

  def extract_wordle_block_from(starting_line, remaining_lines)
    block = [starting_line]

    remaining_lines.each do |line|
      line = line.strip
      break unless line.match?(/^[⬜⬛🟩🟨]+$/)

      block << line
    end

    block.join("\n")
  end
end
