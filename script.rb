data = File.read('data.txt')
require_relative 'wordle'
require_relative 'person_stats'

wordle_summaries = []
other_messages = []

lines = data.split("\n")
lines.each.with_index do |line, index|
  if line.match?(/^Wordle \d+/)
    wordle_summaries << Wordle.parse(index, lines)
  else
    # other_messages << line.strip
  end
end


grouped = wordle_summaries.group_by(&:person)

grouped.each do |person, wordles|
  stats = PersonStats.new(person, wordles)
  stats.calculate
end
