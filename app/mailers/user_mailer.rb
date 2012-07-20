class UserMailer < ActionMailer::Base
  default from: "notifications@worth-reading.org"
 
  def welcome_email(user)
    @user = user

    # NOTE Try and find a way to determine host name versus manually defining host domain
    @url  = "https://evening-fog-9503.herokuapp.com/users/#{user.id}/confirm/#{user.confirmation}"
    mail(to: user.email, subject: "Welcome to Worth Reading")
  end
end
