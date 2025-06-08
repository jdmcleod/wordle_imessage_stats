require 'json'

if ENV['CONTACTS'].nil?
  require 'dotenv/load'
end

class Contact
  def self.name_for(number)
    sanitized_number = number.gsub(/[-+]+/, '')
    contacts = JSON.parse(ENV['CONTACTS'])
    contacts.fetch(sanitized_number, number)
  end
end
