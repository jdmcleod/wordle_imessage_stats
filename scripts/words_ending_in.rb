filename = "data/all_wordle_words.txt"

words_ending_with_ep = File.readlines(filename, chomp: true).select do |word|
  word.match?(/ep\z/i)
end

puts words_ending_with_ep
