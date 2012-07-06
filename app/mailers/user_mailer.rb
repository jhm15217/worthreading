class UserMailer < ActionMailer::Base
  default from: "notifications@example.com"
 
  def welcome_email(user)
    @user = user
    @url  = "http://worthreading.org/login"
    mail(to: user.email, subject: "Welcome to Worth Reading")
  end

  def receive(email)
    puts "Email received"
    puts email

  end  
end