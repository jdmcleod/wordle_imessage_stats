require 'json'

class Contact
  def self.name_for(number)
    sanitized_number = number.gsub(/[^0-9]/, '')
    contacts = JSON.parse(File.read('contacts.json'))
    contacts.fetch("+1#{sanitized_number}", number)
  end
end
