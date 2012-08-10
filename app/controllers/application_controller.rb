class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include UsersHelper

  # default_settings for WillPaginate
  WillPaginate.per_page = 15

  def email_address_list(email_addresses)
    x = email_addresses.split(/,\s*/).map{|x| email_address_parts(x) }
  end

  # Captures formats:
  # "John Doe"<johndoe@example.com>, John Doe<johndoe@example.com>, johndoe@example.com
  def email_address_parts(email_address)
    if parts = (email_address.match('"([^"]*)"<(.*)>') or email_address.match('([a-zA-Z\s.]*)<(.*)>'))
      name = parts.captures[0]
      email_address = parts.captures[1]
    else
      name = ""
    end
    { name: name, email: email_address }
  end
end
