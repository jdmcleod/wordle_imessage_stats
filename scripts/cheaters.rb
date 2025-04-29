require 'csv'

# Read all words from the all_wordle_words.txt file
all_words = File.read("data/all_wordle_words.txt").split("\n")

# Read words from the third column of the history.csv file
used_words = []
CSV.foreach("data/history.csv", headers: false) do |row|
  used_words << row[2] if row[2] # Only take the third column (index 2), if it exists
end

# Normalize data (downcase and strip any extra whitespace)
all_words.map!(&:strip).map!(&:downcase)
used_words.map!(&:strip).map!(&:downcase)

# Subtract the used words from all words
remaining_words = all_words - used_words

# binding.irb
# Output the count of remaining words and percentage
puts "Count of remaining words: #{remaining_words.count}"
percentage_used = ((used_words.count.to_f / all_words.count) * 100).round(2)
puts "#{percentage_used}% of valid guesses have been ruled out by the history list"


