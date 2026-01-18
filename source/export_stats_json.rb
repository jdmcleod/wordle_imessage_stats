require 'json'
require 'date'
require 'net/http'
require 'uri'
require 'active_support/core_ext/date'
require_relative 'wordle_csv_parser'
require_relative 'wordle_stats'
require_relative 'wordle_stats_printer'

class ExportStatsJson
  def initialize
    @all_wordles = WordleCsvParser.new.parse
    @month_wordles = @all_wordles.reject { it.date < Date.today.prev_month }
    @grouped = @month_wordles.group_by(&:person)
    @all_grouped = @all_wordles.group_by(&:person)
    @stats = WordleStats.new
  end

  def run
    daily_data = export_daily_stats
    weekly_data = export_weekly_stats
    daily_messages = export_daily_messages

    combined_data = {
      daily: daily_data,
      weekly: weekly_data,
      daily_messages: daily_messages
    }

    put_in_json_store(combined_data)
  end

  private

  def export_daily_stats
    @grouped.map do |name, wordles|
      {
        name:,
        scores: wordles.map { { date: it.date, score: it.score } }
      }
    end
  end

  def export_weekly_stats
    @all_grouped.map do |name, wordles|
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
  end

  def export_daily_messages
    last_14_days = (0..13).map { |i| (Date.today - 1) - i }.reverse

    last_14_days.map do |date|
      wordle_for_date = @stats.stats.find { |w| w.date.to_date == date }

      if wordle_for_date
        # Capture the output from WordleStatsPrinter
        message = capture_wordle_stats_output(wordle_for_date)
        {
          date: date,
          message: message
        }
      else
        {
          date: date,
          message: nil
        }
      end
    end
  end

  def capture_wordle_stats_output(wordle)
    printer = WordleStatsPrinter.new(@stats, wordle)
    printer.to_s
  rescue => e
    "Error generating message for #{wordle.date}: #{e.message}"
  end

  def put_in_json_store(data)
    # keep a local copy
    File.write(File.join('data', 'wordle_stats.json'), JSON.pretty_generate(data))

    uri = URI('https://api.jsonsilo.com/api/v1/manage/f9b3d14c-db19-402f-be2c-0a3cb3b76a40')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Patch.new(uri)
    request['Content-Type'] = 'application/json'
    request['X-MAN-API'] = ENV['JSON_SILO_KEY']
    request.body = data.to_json

    request.body = {
      "file_name": "wordle-chat-stats",
      "file_data": data,
      "region_name": "api",
      "is_public": false
    }.to_json

    begin
      response = http.request(request)

      if response.code == '200' || response.code == '201'
        # puts "\n\nSuccessfully posted data to API"
      else
        puts "\n\nFailed to post to API. Status: #{response.code}"
      end
    rescue => e
      puts "Error posting to API: #{e.message}"
    end
  end
end
