# frozen_string_literal: true

require_relative '../source/wordle_stats'
require_relative '../source/wordle_stats_printer'
require_relative '../source/export_stats_json'

stats = WordleStats.new
yesterday = Date.today - 1

if stats.today_wordle.date.day == yesterday.day
  WordleStatsPrinter.new(stats, stats.today_wordle).print
else
  WordleStatsPrinter.new(stats, stats.yesterday_wordle).print
end
ExportStatsJson.new.run
