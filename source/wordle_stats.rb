# frozen_string_literal: true

require 'date'
require_relative 'wordle_chat_parser'
require_relative 'wordle_average_web_scraper'
require_relative 'most_impressive_guess'
require_relative 'wordle_history_updater'
require_relative 'wordle_statistic'
require_relative 'luckiest_guess'

class WordleStats
  attr_reader :wordles, :grouped_wordles, :total

  def initialize
    @wordles = fetch_wordles
    @grouped_wordles = calculate_word_statistics
    @total = @grouped_wordles.count
  end

  def display_statistics
    display_word_rankings
    display_impressive_guessers
  end

  def today_wordle
    @today_wordle ||= grouped_wordles.last
  end

  def yesterday_wordle
    @yesterday_wordle ||= grouped_wordles[-2]
  end

  def yesterday_wordle_index
    sorted_wordles.index { _1.wordle_number == recent.wordle_number }
  end

  def yesterday_wordle_difficulty_percentile
    ((yesterday_wordle_index.to_f / total.to_f) * 100.0).round
  end

  def sorted_wordles
    grouped_wordles.sort_by(&:average_score)
  end

  def number_of_players
    @number_of_players ||= wordles.map(&:person).uniq.count
  end

  private

  def fetch_wordles
    WordleHistoryUpdater.new.update
    WordleChatParser.new.parse
  end

  def calculate_word_statistics
    @wordles.group_by(&:answer).map do |answer, wordles|
      WordleStatistic.new(
        answer: answer,
        average_score: calculate_average_score(wordles),
        date: wordles.first.date,
        wordle_number: wordles.first.wordle_number,
        luckiest_guesser: LuckiestGuess.new(wordles).calculate,
        most_impressive_guesser: MostImpressiveGuess.new(wordles).calculate
      )
    end
  end

  def calculate_average_score(wordles)
    (wordles.sum(&:score_for_average) / wordles.count.to_f).round(2)
  end

  def display_word_rankings
    sorted_stats = grouped_wordles.sort_by(&:average_score)
    sorted_stats.each.with_index do |stat, index|
      puts "#{total - index}. #{stat}"
    end
  end

  def display_impressive_guessers
    puts "\nMost impressive guessers"
    grouped_wordles
      .group_by(&:most_impressive_guesser)
      .sort_by { |_, wordles| wordles.count }
      .each { |guesser, wordles| puts "#{guesser.join(', ')} (#{wordles.count})" }
  end
end
