require 'json'

class Contact
  def self.name_for(number)
    sanitized_number = number.gsub(/[-+]+/, '')
    contacts = JSON.parse(File.read('contacts.json'))
    contacts.fetch(sanitized_number, number)
  end
end
