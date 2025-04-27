# frozen_string_literal: true

require_relative '../source/wordle_stats'
require_relative '../source/wordle_stats_printer'

stats = WordleStats.new
today_wordle = stats.today_wordle

if today_wordle.date.day == Date.today.day
  WordleStatsPrinter.new(stats, today_wordle).print
else
  puts "\nToday's wordle hasn't been posted yet. You may need to run scripts/pull_chat.sh\n"
end


