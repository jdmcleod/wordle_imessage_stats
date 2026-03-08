#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'prawn'
require 'prawn/table'
require_relative '../source/person_stats'
require_relative '../source/wordle_csv_parser'
require_relative '../source/wordle_stats'

class SundayPdf
  FONTS_DIR = File.expand_path('../fonts', __dir__)

  # Google-inspired pastel palette
  BG = 'FFFFFF'
  CARD_BG = 'F8F9FA'
  TEXT = '202124'
  TEXT_SECONDARY = '5F6368'
  BLUE = '4285F4'
  GREEN = '34A853'
  YELLOW = 'FBBC04'
  RED = 'EA4335'
  BORDER = 'DADCE0'
  HEADER_BG = 'E8F0FE'
  ROW_EVEN = 'FFFFFF'
  ROW_ODD = 'F8F9FA'
  GOLD = 'E6A817'
  SILVER = '78909C'
  BRONZE = 'A1887F'
  STREAK_BG = 'E8EAED'
  PASTEL_BLUE = 'D2E3FC'
  PASTEL_GREEN = 'CEEAD6'
  PASTEL_RED = 'FAD2CF'
  PASTEL_YELLOW = 'FEF7E0'

  def initialize
    @saturday = Date.today - 1
    @sunday = @saturday - 6
    @all_wordles = WordleCsvParser.new.parse
    @week_wordles = @all_wordles.reject { |w| w.date.to_date < @sunday || w.date.to_date > @saturday }
    @stats = WordleStats.new(@all_wordles.reject { |w| w.date.to_date > @saturday })
    @week_players = @week_wordles.map(&:person).uniq
  end

  def generate(output_path = nil)
    output_path ||= "data/weekly_wordle_report_#{@saturday.strftime('%Y_%m_%d')}.pdf"

    Prawn::Document.generate(output_path, page_size: 'A4', margin: 30) do |pdf|
      register_fonts(pdf)
      pdf.font 'Inter'
      pdf.font_size 10
      pdf.fill_color TEXT
      draw_header(pdf)
      draw_leaderboard(pdf)
      draw_daily_breakdown(pdf)
      draw_bottom_row(pdf)
    end

    puts "PDF generated: #{output_path}"
    output_path
  end

  private

  def register_fonts(pdf)
    pdf.font_families.update(
      'Poppins' => {
        normal: File.join(FONTS_DIR, 'Poppins-Regular.ttf'),
        bold: File.join(FONTS_DIR, 'Poppins-Bold.ttf'),
        semibold: File.join(FONTS_DIR, 'Poppins-SemiBold.ttf')
      },
      'Inter' => {
        normal: File.join(FONTS_DIR, 'Inter-Regular.ttf'),
        bold: File.join(FONTS_DIR, 'Inter-Bold.ttf'),
        semibold: File.join(FONTS_DIR, 'Inter-SemiBold.ttf')
      }
    )
  end

  def draw_header(pdf)
    # Pastel blue banner
    pdf.fill_color PASTEL_BLUE
    pdf.fill_rounded_rectangle [0, pdf.cursor + 5], pdf.bounds.width, 52, 8

    pdf.fill_color BLUE
    pdf.font('Poppins') do
      pdf.text_box 'Weekly Wordle Report', size: 24, style: :bold, align: :center, at: [0, pdf.cursor], width: pdf.bounds.width
    end
    pdf.move_down 30
    pdf.fill_color TEXT_SECONDARY
    pdf.text "#{@sunday.strftime('%b %-d')} - #{@saturday.strftime('%b %-d, %Y')}", size: 11, align: :center
    pdf.move_down 18
    pdf.fill_color TEXT
  end

  def draw_leaderboard(pdf)
    section_heading(pdf, 'Leaderboard')

    stats = weekly_player_stats
    header = ['#', 'Name', 'Avg', '1', '2', '3', '4', '5', '6', 'X', 'Best']
    rows = stats.each_with_index.map do |s, i|
      [(i + 1).to_s, s[:name], s[:avg].to_s, s[:'1'], s[:'2'], s[:'3'], s[:'4'], s[:'5'], s[:'6'], s[:'X'], s[:best_guess]]
    end

    table_data = [header] + rows
    col_widths = [25, 90, 40, 28, 28, 28, 28, 28, 28, 28, 38]

    pdf.table(table_data, width: col_widths.sum, cell_style: { size: 9, text_color: TEXT, border_width: 0.5, border_color: BORDER, padding: [5, 4, 5, 4] }, column_widths: col_widths) do |t|
      t.row(0).font_style = :bold
      t.row(0).background_color = HEADER_BG
      t.row(0).text_color = BLUE
      t.columns(0).align = :center
      t.columns(2..10).align = :center

      rows.each_with_index do |_, i|
        t.row(i + 1).background_color = i.even? ? ROW_EVEN : ROW_ODD
      end

      if rows.size >= 1
        t.row(1).background_color = 'FFF8E1'
        t.row(1).text_color = GOLD
        t.row(1).font_style = :bold
      end
      if rows.size >= 2
        t.row(2).background_color = 'ECEFF1'
        t.row(2).text_color = SILVER
      end
      if rows.size >= 3
        t.row(3).background_color = 'EFEBE9'
        t.row(3).text_color = BRONZE
      end
    end

    pdf.move_down 12
  end

  def draw_daily_breakdown(pdf)
    section_heading(pdf, 'Daily Breakdown')

    daily_stats = @stats.stats
      .select { |s| s.date.to_date >= @sunday && s.date.to_date <= @saturday }
      .sort_by(&:date)

    header = ['Day', 'Word', 'Avg', 'Best Guess', 'Losses']
    rows = daily_stats.map do |stat|
      day_wordles = @week_wordles.select { |w| w.wordle_number == stat.wordle_number }
      losers = day_wordles.select(&:lost?).map(&:person)

      [
        stat.date.strftime('%a %-d'),
        stat.answer&.upcase || '???',
        stat.average_score.to_s,
        stat.most_impressive_guesser,
        losers.empty? ? '-' : losers.join(', ')
      ]
    end

    table_data = [header] + rows
    col_widths = [50, 55, 38, 180, 112]

    pdf.table(table_data, width: col_widths.sum, cell_style: { size: 9, text_color: TEXT, border_width: 0.5, border_color: BORDER, padding: [4, 5, 4, 5] }, column_widths: col_widths) do |t|
      t.row(0).font_style = :bold
      t.row(0).background_color = HEADER_BG
      t.row(0).text_color = BLUE
      t.columns(2).align = :center

      rows.each_with_index do |row, i|
        t.row(i + 1).background_color = i.even? ? ROW_EVEN : ROW_ODD
        t.row(i + 1).column(4).text_color = RED unless row[4] == '-'
      end
    end

    pdf.move_down 12
  end

  def draw_bottom_row(pdf)
    left_width = 255
    right_width = 255
    gap = 25
    start_y = pdf.cursor

    pdf.bounding_box([0, start_y], width: left_width) do
      draw_streaks_section(pdf)
    end

    left_end_y = pdf.cursor

    pdf.bounding_box([left_width + gap, start_y], width: right_width) do
      draw_performance_section(pdf)
      pdf.move_down 10
      draw_highlights_section(pdf)
    end

    right_end_y = pdf.cursor
    pdf.move_cursor_to [left_end_y, right_end_y].min
  end

  def draw_streaks_section(pdf)
    section_heading(pdf, 'Current Streaks')

    streaks = calculate_current_streaks.select { |s| @week_players.include?(s[:person]) }
    return if streaks.empty?

    max_streak = streaks.first[:streak]
    bar_max_width = 230

    streaks.each_with_index do |s, i|
      bar_width = [s[:streak].to_f / (max_streak + 1) * bar_max_width, 14].max
      bar_color = i == 0 ? GREEN : BLUE
      label = "#{s[:person]}: #{s[:streak]}"

      # Track background
      pdf.fill_color STREAK_BG
      pdf.fill_rounded_rectangle [0, pdf.cursor], bar_max_width, 17, 4

      # Filled bar
      pdf.fill_color bar_color
      pdf.fill_rounded_rectangle [0, pdf.cursor], bar_width, 17, 4

      # Place label inside bar if wide enough, otherwise after the bar
      if bar_width > 80
        pdf.fill_color BG
        pdf.draw_text label, at: [6, pdf.cursor - 12], size: 8, style: :bold
      else
        pdf.fill_color TEXT
        pdf.draw_text label, at: [bar_width + 6, pdf.cursor - 12], size: 8
      end
      pdf.move_down 21
    end

    pdf.fill_color TEXT
  end

  def draw_performance_section(pdf)
    section_heading(pdf, 'Chat Performance')

    all_wordles = @all_wordles.reject { |w| w.date.to_date > @saturday }
    weekly_avgs = calculate_weekly_averages(all_wordles)
    return if weekly_avgs.empty?

    all_avg_values = weekly_avgs.map { |w| w[:average] }
    current = weekly_avgs.find { |w| w[:week_start] >= @sunday - 1 && w[:week_start] <= @sunday + 1 } || weekly_avgs.last

    percentile = calculate_percentile(current[:average], all_avg_values)
    perf = performance_label(percentile)
    pill_color = perf_color(percentile)

    pdf.fill_color TEXT
    pdf.text "This Week's Average: #{current[:average]}", size: 10, style: :bold
    pdf.move_down 2

    # Rating pill
    pill_text = "#{perf}  -  #{percentile}th percentile"
    pdf.fill_color pill_color
    pdf.fill_rounded_rectangle [0, pdf.cursor], 170, 16, 8
    pdf.fill_color TEXT
    pdf.draw_text pill_text, at: [8, pdf.cursor - 12], size: 8, style: :bold
    pdf.move_down 22

    pdf.fill_color TEXT_SECONDARY
    weekly_avgs.last(5).each do |w|
      week_end = w[:week_start] + 6
      marker = w == current ? '  <<' : ''
      p_rank = calculate_percentile(w[:average], all_avg_values)
      pdf.text "#{w[:week_start].strftime('%b %-d')}-#{week_end.strftime('%-d')}: #{w[:average]} (#{p_rank}%)#{marker}", size: 8
    end

    pdf.fill_color TEXT
  end

  def draw_highlights_section(pdf)
    section_heading(pdf, 'Highlights')

    facts = []

    daily = @stats.stats.select { |s| s.date.to_date >= @sunday && s.date.to_date <= @saturday }
    if daily.any?
      hardest = daily.max_by(&:average_score)
      easiest = daily.min_by(&:average_score)
      facts << "Hardest: #{hardest.answer&.upcase} (#{hardest.average_score})"
      facts << "Easiest: #{easiest.answer&.upcase} (#{easiest.average_score})"
    end

    aces = @week_wordles.select { |w| w.score == 1 }
    aces.each { |a| facts << "#{a.person} got a hole-in-one on #{a.answer&.upcase}!" }

    twos = @week_wordles.select { |w| w.score == 2 }.group_by(&:person)
    if twos.any?
      best_two = twos.max_by { |_, ws| ws.size }
      facts << "Most 2-guess solves: #{best_two[0]} (#{best_two[1].size})" if best_two[1].size > 1
    end

    grouped = @week_wordles.group_by(&:person)
    perfect = grouped.select { |_, ws| ws.size == 7 && ws.none?(&:lost?) }.keys
    facts << "Perfect week: #{perfect.join(', ')}" if perfect.any?

    missed = grouped.select { |_, ws| ws.size < 7 }
    missed.each { |name, ws| facts << "#{name} missed #{7 - ws.size} day#{'s' if ws.size < 6}" }

    facts << "Total games: #{@week_wordles.size}"

    pdf.fill_color TEXT_SECONDARY
    facts.each do |fact|
      pdf.text "- #{fact}", size: 8
      pdf.move_down 1
    end
    pdf.fill_color TEXT
  end

  # --- Data helpers ---

  def weekly_player_stats
    grouped = @week_wordles.group_by(&:person)
    grouped.map do |person, person_wordles|
      PersonStats.new(person, person_wordles, @week_wordles, punish_misses: true).calculate
    end.sort_by { [_1[:avg], -_1[:best_guess]] }
  end

  def calculate_current_streaks
    yesterday_cutoff = Time.new(@saturday.year, @saturday.month, @saturday.day, 23, 59, 0)

    all_wordles = @all_wordles.reject do |wordle|
      Time.new(wordle.date.year, wordle.date.month, wordle.date.day) > yesterday_cutoff
    end

    all_wordles.group_by(&:person).map do |person, wordles|
      sorted = wordles.sort_by { |w| -w.wordle_number }
      current_streak = 0
      expected = sorted.first.wordle_number

      sorted.each do |w|
        if w.wordle_number == expected && !w.lost?
          current_streak += 1
          expected -= 1
        else
          break if w.wordle_number < expected || w.lost?
        end
      end

      { person: person, streak: current_streak }
    end.sort_by { |s| -s[:streak] }
  end

  def week_start_date(date)
    date.to_date - date.to_date.wday
  end

  def calculate_weekly_averages(wordles)
    wordles
      .group_by { |w| week_start_date(w.date) }
      .map do |week_start, week_wordles|
        scores = week_wordles.map(&:score_for_average)
        { week_start: week_start, average: (scores.sum / scores.size.to_f).round(2), count: scores.size }
      end
      .sort_by { |w| w[:week_start] }
  end

  def calculate_percentile(value, all_values)
    return 0 if all_values.empty?

    count_below = all_values.count { |v| v < value }
    ((count_below.to_f / all_values.size) * 100).round(1)
  end

  def performance_label(percentile)
    if percentile < 25 then 'Excellent'
    elsif percentile < 50 then 'Good'
    elsif percentile < 75 then 'Average'
    else 'Below Average'
    end
  end

  def perf_color(percentile)
    if percentile < 25 then PASTEL_GREEN
    elsif percentile < 50 then PASTEL_BLUE
    elsif percentile < 75 then PASTEL_YELLOW
    else PASTEL_RED
    end
  end

  def section_heading(pdf, title)
    pdf.fill_color BLUE
    pdf.font('Poppins') do
      pdf.text title, size: 13, style: :bold
    end
    pdf.move_down 2
    pdf.stroke_color BORDER
    pdf.line_width = 0.5
    pdf.stroke_horizontal_rule
    pdf.move_down 6
    pdf.fill_color TEXT
  end
end

SundayPdf.new.generate
