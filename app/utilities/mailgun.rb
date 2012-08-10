require 'rest_client'
require 'json'
class Mailgun
  API_LOG_URL = ENV['MAILGUN_API_URL']
  API_KEY = ENV['MAILGUN_API_KEY']

  def self.get_logs
    logs = JSON.parse(RestClient.get "https://api:#{API_KEY}@#{API_LOG_URL}/log")
    logs["items"].each do |i| 
      msg = "#{i["message"]} at #{i["created_at"]}" 
      puts msg
    end
  end
end
