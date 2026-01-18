# frozen_string_literal: true

require_relative 'wordle_csv_parser'

class MonthWinnerTable
  def self.print
    new.print
  end

  def print
    columns = []
    data = []

    8.times do |i|
      prev_month_date = Date.today.prev_month(i)
      start_date = Date.new(prev_month_date.year, prev_month_date.month, 1)
      end_date = Date.new(prev_month_date.year, prev_month_date.month, -1)

      column_name = start_date.strftime('%b %Y').to_sym

      columns << column_name

      wordles_in_period = grouped_in_period start_date, end_date

      (1..11).each_with_object({}) do |position, hash|
        position_key = case position
                       when 1 then :first
                       when 2 then :second
                       when 3 then :third
                       else "#{position}th".to_sym
                       end

        player = wordles_in_period[position - 1]
        player_name = player ? "#{player[:name]} (#{player[:avg].round(1)}, #{player[:best_guess]})" : '-'

        row = data.detect { it && it[:position] == position_key }
        data.push({ position: position_key }) if row.nil?
        row = data.detect { it && it[:position] == position_key }

        row[column_name] = player_name
      end
    end

    puts TableTennis.new(data, table_options(columns))
  end

  private

  def table_options(columns)
    {
      color: true,
      columns:,
      zebra: true,
      titleize: true,
      title: 'Monthly Winners'
    }
  end

  def grouped_in_period(start_date, end_date)
    target_wordles = wordles.select { it.date > start_date && it.date <= end_date  }

    target_wordles.group_by(&:person)
      .map do |person, person_wordles|
        stats = PersonStats.new(person, person_wordles, target_wordles)
        stats.calculate
      end.sort_by { it[:avg] }
  end

  def wordles
    @wordles ||= WordleCsvParser.new.parse
  end
end
