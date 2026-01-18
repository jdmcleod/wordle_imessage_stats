require 'csv'

all_words = File.read("data/all_wordle_words.txt").split("\n")

used_words = []
CSV.foreach("data/history.csv", headers: false) do |row|
  used_words << row[2] if row[2]
end

all_words.map!(&:strip).map!(&:downcase)
used_words.map!(&:strip).map!(&:downcase)

remaining_words = all_words - used_words

puts "Count of remaining words: #{remaining_words.count}"
percentage_used = ((used_words.count.to_f / all_words.count) * 100).round(2)
puts "#{percentage_used}% of valid guesses have been ruled out by the history list"


