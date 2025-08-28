require 'json'
require 'date'
require 'active_support/core_ext/date'
require_relative 'wordle_chat_parser'
require_relative 'wordle_stats'

class ExportStatsJson
  def initialize
    @all_wordles = WordleChatParser.new.parse
    @month_wordles = @all_wordles.reject { it.date < Date.today.prev_month }
    @grouped = @month_wordles.group_by(&:person)
    @all_grouped = @all_wordles.group_by(&:person)
  end

  def run
    export_daily_stats
    export_weekly_stats
  end

  private

  def export_daily_stats
    output = @grouped.map do |name, wordles|
      {
        name:,
        scores: wordles.map { { date: it.date, score: it.score } }
      }
    end

    File.open('data/wordle_stats.json', 'w') do |f|
      f.write(JSON.pretty_generate(output))
    end
  end

  def export_weekly_stats
    weekly_output = @all_grouped.map do |name, wordles|
      grouped_by_week = wordles.group_by { |w| w.date.beginning_of_week(:monday).to_date }
      weekly_scores = grouped_by_week.map do |week_start, week_wordles|
        avg_score = week_wordles.sum(&:score).to_f / week_wordles.size.to_f
        { date: week_start, score: avg_score.round(2) }
      end.sort_by { |entry| entry[:date] }

      {
        name:,
        scores: weekly_scores
      }
    end

    File.open('data/wordle_stats_weekly.json', 'w') do |f|
      f.write(JSON.pretty_generate(weekly_output))
    end
  end
end
