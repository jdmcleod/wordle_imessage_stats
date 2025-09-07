require 'json'
require 'date'
require 'net/http'
require 'uri'
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
    daily_data = export_daily_stats
    weekly_data = export_weekly_stats

    combined_data = {
      daily: daily_data,
      weekly: weekly_data
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

  def put_in_json_store(data)
    # keep a local copy
    File.write(File.join('data', 'wordle_stats.json'), JSON.pretty_generate(data))

    uri = URI('https://api.jsonsilo.com/api/v1/manage/f9b3d14c-db19-402f-be2c-0a3cb3b76a40')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Patch.new(uri)
    request['Content-Type'] = 'application/json'
    request['X-MAN-API'] = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX3V1aWQiOiJzMGRLT3JPTGk2TWxsUDJJUFpDb2c2TGN5eUozIiwiaXNzIjoiaHR0cHM6Ly9qc29uc2lsby5jb20iLCJleHAiOjE3NTk4NjcwNzd9.zOjRlBAiL_wBS9qN7cVq4E6X7HmGpGbu898D0z4GCZg'
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
        puts "Successfully posted data to API"
        puts "Response: #{response.body}"
      else
        puts "Failed to post to API. Status: #{response.code}"
        puts "Response: #{response.body}"
      end
    rescue => e
      puts "Error posting to API: #{e.message}"
    end
  end
end
