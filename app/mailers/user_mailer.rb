class UserMailer < ActionMailer::Base
  default from: "notifications@worth-reading.org"
 
  def welcome_email(user)
    @user = user

    # NOTE Try and find a way to determine host name versus manually defining host domain
    @url =  confirm_email_url(host: "evening-fog-9503.herokuapp.com", 
                               id: user.id, 
                               confirmation_token: user.confirmation_token,
                               protocol: 'https')
    mail(to: user.email, subject: "Welcome to Worth Reading")
  end
end
