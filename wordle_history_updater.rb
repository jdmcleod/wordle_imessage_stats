require 'nokogiri'
require 'open-uri'
require 'csv'

class WordleHistoryUpdater
  URL = 'https://wordfinder.yourdictionary.com/wordle/answers/'

  def update
    doc = fetch_document
    words = parse_words(doc)
    save_to_csv(words)
  rescue OpenURI::HTTPError => e
    puts "Failed to open URL: #{e}"
  rescue SocketError => e
    puts "Network error: #{e}"
  rescue StandardError => e
    puts "An unexpected error occurred: #{e}"
  end

  private

  def fetch_document
    html = URI.open(URL)
    Nokogiri::HTML(html)
  end

  def parse_words(doc)
    raw_words = doc.css('tr')
    raw_words.map do |word|
      text = word.text
      next if text.include?('Wordle')
      word.text
          .gsub("\t", '')
          .gsub("\n", '')
          .delete('Today')
          .delete('Reveal')
          .split(' ')
          .map(&:strip)
          .compact # -> [month, day, number, word]
    end.compact
  end

  def save_to_csv(words)
    CSV.open('history.csv', 'w') do |csv|
      words.each_with_index do |wordle_data, index|
        date = Date.today - index
        csv << [date.strftime('%Y-%m-%d'), wordle_data[2], wordle_data.last.upcase]
      end
    end
  rescue StandardError => e
    puts "Error writing to CSV: #{e}"
  end
end
