# frozen_string_literal: true

require_relative '../source/wordle_stats'
require_relative '../source/wordle_stats_printer'
require_relative '../source/export_stats_json'
require_relative '../source/wordles_csv_parser'

stats = WordleStats.new
wordles_parser = WordlesCsvParser.new

today = Date.today
five_days_ago = today - 5
start_of_today = DateTime.new(today.year, today.month, today.day, 0, 0, 0)

unsent_wordle_numbers = wordles_parser.get_unsent_wordles_in_range(five_days_ago.to_datetime, start_of_today)

if unsent_wordle_numbers.empty?
  puts "No unsent Wordles to report"
  exit 0
end

messages = []
unsent_wordle_numbers.each do |wordle_number|
  wordle_stat = stats.wordle_for_number(wordle_number)
  next unless wordle_stat

  printer = WordleStatsPrinter.new(stats, wordle_stat)
  messages << printer.to_s

  wordles_parser.mark_wordle_as_sent(wordle_number)
end

puts messages.join("\n\n")

ExportStatsJson.new.run
