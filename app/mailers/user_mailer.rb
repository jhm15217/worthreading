class UserMailer < ActionMailer::Base
  default from: "notifications@worth-reading.org"

  HOST = "evening-fog-9503.herokuapp.com"
 
  def welcome_email(user)
    @user = user

    @url =  confirm_email_url(host: if Rails.env.production?
                                      "evening-fog-9503.herokuapp.com"
                                    else
                                      "localhost:3000"
                                    end,
                               id: user.id, 
                               confirmation_token: user.confirmation_token,
                               protocol: if Rails.env.production?
                                           'https'
                                         else
                                           'http'
                                         end)
    mail(to: user.email, subject: "Welcome to Worth Reading")
  end

  def first_pt_msg(user, email)
    body = parse_message(email.body)

    mail(from: email.from, 
         to: user.email, 
         subject: email.subject)
  end
end
