module EmailsHelper

  def email_address_list(email_addresses)
    x = email_addresses.split(/,\s*/).map { |x| email_address_parts(x) }
  end

  def email_address_parts(email_address)
    if parts = (email_address.match('"([^"]*)"<(.*)>') or email_address.match('([a-zA-Z\s.]*)<(.*)>'))
      name = parts.captures[0]
      email_address = parts.captures[1]
    else
      name = ""
    end
    { name: name, email: email_address }
  end
  
  def check_addresses(email_addresses)
    email_addresses.split(/,\s*/).each do |email| 
      unless email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
        errors.add(:email_addresses, "are invalid due to #{email}")
      end
    end
  end
  
end
