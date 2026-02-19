#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'table_tennis'
require_relative '../source/person_stats'
require_relative '../source/wordle_csv_parser'
require_relative '../source/wordle_stats'
require_relative '../source/month_winner_table'

def stats_table_options(columns, title)
  {
    color_scales: { avg: :gyr, '1': :b, '2': :b, '3': :b, '4': :b, '5': :b, '6': :b, 'X': :b, best_guess: :g },
    color: true,
    columns:,
    title:,
    titleize: true,
    zebra: true,
  }
end

def get_stats_from_date(cutoff_date = Date.today - 1000, punish_misses: false)
  yesterday = Date.today - 1
  yesterday_cutoff = Time.new(yesterday.year, yesterday.month, yesterday.day, 23, 59, 0)
  all_worldes = WordleCsvParser.new.parse.reject do |wordle|
    wordle.date.to_date < cutoff_date || Time.new(wordle.date.year, wordle.date.month, wordle.date.day) > yesterday_cutoff
  end

  grouped = all_worldes.group_by(&:person)

  stats = grouped.map do |person, person_wordles|
    stats = PersonStats.new(person, person_wordles, all_worldes, punish_misses:)
    stats.calculate
  end.sort_by { _1[:avg] }

  stats
end

def print_from_date(cutoff_date = Date.today - 1000, table_name = 'Wordle Stats', punish_misses: false)
  stats = get_stats_from_date(cutoff_date, punish_misses: punish_misses)
  puts TableTennis.new(stats, stats_table_options(stats.first.keys, table_name))
  stats
end

def first_sunday_of_month?
  today = Date.today
  return false unless today.sunday?

  today.day <= 7
end

def calculate_current_streaks
  yesterday = Date.today - 1
  yesterday_cutoff = Time.new(yesterday.year, yesterday.month, yesterday.day, 23, 59, 0)

  all_wordles = WordleCsvParser.new.parse.reject do |wordle|
    Time.new(wordle.date.year, wordle.date.month, wordle.date.day) > yesterday_cutoff
  end

  grouped = all_wordles.group_by(&:person)

  streaks = grouped.map do |person, wordles|
    sorted_wordles = wordles.sort_by { |w| -w.wordle_number }

    current_streak = 0
    expected_number = sorted_wordles.first.wordle_number

    sorted_wordles.each do |wordle|
      if wordle.wordle_number == expected_number && !wordle.lost?
        current_streak += 1
        expected_number -= 1
      else
        break if wordle.wordle_number < expected_number
        break if wordle.lost?
      end
    end

    { person: person, streak: current_streak }
  end

  streaks.sort_by { |s| -s[:streak] }
end

def print_streaks
  streaks = calculate_current_streaks
  longest_streak = streaks.first

  puts "\nStreaks:\n\n"

  streaks.each_with_index do |stat, index|
    prefix = index == 0 ? "[#1] " : "     "
    puts "#{prefix}#{stat[:person]}: #{stat[:streak]}"
  end

  puts "\n#{longest_streak[:person]} has the longest current streak at #{longest_streak[:streak]} days!\n\n"
end

weekly_stats = print_from_date(Date.today - 7, 'Weekly stats', punish_misses: true)

if first_sunday_of_month?
  print_from_date(Date.today - 1000, 'All time stats')
  MonthWinnerTable.print
end

streaks = calculate_current_streaks
print_streaks

def week_start_date(date)
  date.to_date - date.to_date.wday
end

def calculate_weekly_averages(wordles)
  wordles
    .group_by { |w| week_start_date(w.date) }
    .map do |week_start, week_wordles|
      scores = week_wordles.map(&:score_for_average)
      average = (scores.sum / scores.size.to_f).round(2)
      {
        week_start: week_start,
        average: average,
        count: scores.size
      }
    end
    .sort_by { |w| w[:week_start] }
end

def calculate_percentile(value, all_values)
  return 0 if all_values.empty?

  count_below = all_values.count { |v| v < value }
  ((count_below.to_f / all_values.size) * 100).round(1)
end

def performance_level(percentile)
  if percentile < 25
    { text: "Excellent", color: "#10b981" }
  elsif percentile < 50
    { text: "Good", color: "#3b82f6" }
  elsif percentile < 75
    { text: "Average", color: "#f59e0b" }
  else
    { text: "Below Average", color: "#ef4444" }
  end
end

stats = WordleStats.new
wordles = stats.wordles

weekly_averages = calculate_weekly_averages(wordles)

unless weekly_averages.empty?
  trailing_week_date = Date.today - 7
  trailing_week_start = week_start_date(trailing_week_date)
  current_week = weekly_averages.find { |w| w[:week_start] == trailing_week_start } || weekly_averages.last

  all_averages = weekly_averages.map { |w| w[:average] }

  percentile = calculate_percentile(current_week[:average], all_averages)
  performance = performance_level(percentile)

  current_week_end = current_week[:week_start] + 6

  puts "\nWeek: #{current_week[:week_start].strftime('%b %-d')} - #{current_week_end.strftime('%b %-d, %Y')}"
  puts "Chat Average: #{current_week[:average]} (#{percentile}%)"
  puts "Performance: #{performance[:text]} (Top #{percentile < 25 ? 25 : percentile < 50 ? 50 : percentile < 75 ? 75 : 100}%)"

  if weekly_averages.size >= 5
    puts "\nRecent Weeks:"
    weekly_averages.last(5).each do |week|
      week_end = week[:week_start] + 6
      marker = week == current_week ? " <- Trailing" : ""
      percentile_rank = calculate_percentile(week[:average], all_averages)
      puts "  #{week[:week_start].strftime('%b %-d')} - #{week_end.strftime('%b %-d')}: #{week[:average]} (#{week[:count]} games, #{percentile_rank}% percentile)#{marker}"
    end
  end

  puts "\nGenerating weekly report image..."
  require_relative 'generate_week_image'
  recent_weeks_data = weekly_averages.last(5)
  # generate_week_image(weekly_stats, streaks, current_week, current_week_end, percentile, performance[:text], performance[:color], recent_weeks_data, all_averages)
end
