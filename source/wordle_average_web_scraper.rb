require 'selenium-webdriver'
require 'json'

class WordleAverageWebScraper
  URL = 'https://engaging-data.com/pages/scripts/wordlebot/wordlegraph4.html'
  CACHE_FILE = 'data/wordle_averages_cache.json'

  def parse(wordle_number)
    cached_result = read_cache[wordle_number.to_s]
    return cached_result if cached_result

    driver = setup_driver
    begin
      driver.get(URL)
      wait = Selenium::WebDriver::Wait.new(timeout: 10)
      select_element = wait.until { driver.find_element(id: 'wordlenum') }

      # Try to find and click the option, rescue if not found
      begin
        select_element.find_element(css: "option[value='#{wordle_number}']").click
      rescue Selenium::WebDriver::Error::NoSuchElementError
        return nil
      end

      avg_element = wait.until { driver.find_element(id: 'avg') }
      result = avg_element.text.to_f
      update_cache(wordle_number, result)
      result
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    rescue Selenium::WebDriver::Error::TimeoutError
      nil
    rescue StandardError => e
      puts "An unexpected error occurred: #{e}"
      nil
    ensure
      driver.quit
    end
  end

  private

  def read_cache
    return {} unless File.exist?(CACHE_FILE)
    JSON.parse(File.read(CACHE_FILE))
  rescue JSON::ParserError
    {}
  end

  def update_cache(wordle_number, result)
    cache = read_cache
    cache[wordle_number.to_s] = result
    File.write(CACHE_FILE, JSON.generate(cache))
  end

  def setup_driver
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    Selenium::WebDriver.for :chrome, options: options
  end
end
