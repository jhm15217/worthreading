module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: "Profile pic", class: "gravatar")
  end
  
  def find_or_register(email_address)
     User.where(email: email_address.downcase).first_or_create!(name:"Unknown",password:"Unknown", password_confirmation:"Unknown", email_notify: true, forward: true)
   rescue
     nil
  end
end
