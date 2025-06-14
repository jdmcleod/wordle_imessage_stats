# frozen_string_literal: true

require 'date'
require_relative 'wordle_chat_parser'
require_relative 'wordle_average_web_scraper'
require_relative 'most_impressive_guess'
require_relative 'wordle_history_updater'
require_relative 'wordle_statistic'
require_relative 'luckiest_guess'

class WordleStats
  attr_reader :wordles, :stats, :total

  def initialize(wordles_override=nil)
    @wordles_override = wordles_override
    @wordles = fetch_wordles
    @stats = calculate_word_statistics
    @total = @stats.count
  end

  def display_statistics
    display_word_rankings
    display_impressive_guessers
  end

  def today_wordle
    @today_wordle ||= stats.last
  end

  def yesterday_wordle
    @yesterday_wordle ||= stats[-2]
  end

  def yesterday_wordle_index
    sorted_wordles.index { _1.wordle_number == recent.wordle_number }
  end

  def yesterday_wordle_difficulty_percentile
    ((yesterday_wordle_index.to_f / total.to_f) * 100.0).round
  end

  def sorted_wordles
    stats.sort_by(&:average_score)
  end

  def number_of_players
    @number_of_players ||= wordles.map(&:person).uniq.count
  end

  def impressive_guessers
    stats
      .group_by { _1.most_impressive_guesser }
      .sort_by { |_, wordles| wordles.count }
  end

  def impressive_guesses_for(person)
    stats.count { it.most_impressive_guesser.include?(person) }
  end

  def wordles
    @wordles_override || @wordles
  end

  private

  def fetch_wordles
    WordleHistoryUpdater.new.update
    WordleChatParser.new.parse
  end

  def calculate_word_statistics
    wordles.group_by(&:answer).map do |answer, wordles|
      WordleStatistic.new(
        answer: answer,
        average_score: calculate_average_score(wordles),
        date: wordles.first.date,
        wordle_number: wordles.first.wordle_number,
        luckiest_guesser: LuckiestGuess.new(wordles).calculate,
        most_impressive_guess: MostImpressiveGuess.new(wordles).calculate
      )
    end
  end

  def calculate_average_score(wordles)
    return 0 if wordles.empty?

    (wordles.sum(&:score_for_average) / wordles.count.to_f).round(2)
  end

  def display_word_rankings
    sorted_stats = stats.sort_by(&:average_score)
    sorted_stats.each.with_index do |stat, index|
      puts "#{total - index}. #{stat}"
    end
  end

  def display_impressive_guessers
    puts "\nMost impressive guessers"
    impressive_guessers.each { |guesser, wordles| puts "#{guesser} (#{wordles.count})" }
  end
end
