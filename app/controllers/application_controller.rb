class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include UsersHelper

  # default_settings for WillPaginate
  WillPaginate.per_page = 15

   VALID_EMAIL_REGEX = '^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$'

  def email_address_list(email_addresses)
    result = []
    until !email_addresses
        x = email_addresses.match('\s*("[^"]*"[^,]*|\s*[^,]*)(,(.*)|\s*)')
        if x
          result = result + [x.captures[0]]
          email_addresses = x.captures[2]
        else
          email_addresses = nil
        end
      end
    result.map{|x| email_address_parts(x) }.select{|x|x}
  end

  # Captures formats:
  # "John Doe"<johndoe@example.com>, John Doe<johndoe@example.com>, johndoe@example.com
  def email_address_parts(email_address)
    if parts = (email_address.match('"([^"]*)"\s*<(.*)>') or email_address.match('([a-zA-Z\s.]*)<(.*)>'))
      name = parts.captures[0]
      email_address = parts.captures[1]
    else
      name = ""
    end
    if email_address.match(VALID_EMAIL_REGEX)
      { name: name.strip, email: email_address.strip }
    else
      nil
    end
  end

end
