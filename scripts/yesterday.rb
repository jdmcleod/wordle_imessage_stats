# frozen_string_literal: true

require_relative '../source/wordle_stats'
require_relative '../source/wordle_stats_printer'

stats = WordleStats.new
yesterday = Date.today - 1

if stats.yesterday_wordle.date.day == yesterday.day
  WordleStatsPrinter.new(stats, stats.yesterday_wordle).print
elsif stats.today_wordle.date.day == yesterday.day
  WordleStatsPrinter.new(stats, stats.today_wordle).print
else
  puts "\nYesterday's wordle hasn't been posted yet. You may need to run scripts/pull_chat.sh\n"
end

