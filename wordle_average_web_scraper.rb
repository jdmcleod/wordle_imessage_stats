require 'selenium-webdriver'

class WordleAverageWebScraper
  URL = 'https://engaging-data.com/pages/scripts/wordlebot/wordlegraph4.html'

  def parse(wordle_number)
    driver = setup_driver
    begin
      driver.get(URL)
      wait = Selenium::WebDriver::Wait.new(timeout: 10)
      select_element = wait.until { driver.find_element(id: 'wordlenum') }
      select_element.find_element(css: "option[value='#{wordle_number}']").click
      avg_element = wait.until { driver.find_element(id: 'avg') }
      avg_element.text.to_f
    rescue Selenium::WebDriver::Error::TimeoutError
      puts "Timeout waiting for element with id 'avg'"
      nil
    rescue StandardError => e
      puts "An unexpected error occurred: #{e}"
      nil
    ensure
      driver.quit
    end
  end

  private

  def setup_driver
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    Selenium::WebDriver.for :chrome, options: options
  end
end
