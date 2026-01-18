# frozen_string_literal: true

require_relative '../source/wordle_stats'
require_relative '../source/wordle_stats_printer'

wordle_number = ARGV[0] ? ARGV[0].to_i : nil

stats = WordleStats.new

if wordle_number
  wordle = stats.stats.find { it.wordle_number == wordle_number }

  if wordle
    WordleStatsPrinter.new(stats, wordle).print
  else
    puts "\nWordle ##{wordle_number} not found. You may need to run scripts/pull_chat.sh\n"
  end
end
