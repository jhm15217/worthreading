module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: "Profile pic", class: "gravatar")
  end
  
  def find_or_register(email_address)
    if result = User.find_by_email(email_address)
      result
    else
      result = User.new(name:"Unknown", email:email_address, password:"Unknown", password_confirmation:"Unknown")
      result.save
      result
    end
  end
end
