class UserMailer < ActionMailer::Base
  default from: "notifications@worth-reading.org"

  # Constants
  MORE_INDICATOR = "<more>"
  PROD_URL = "evening-fog-9503.herokuapp.com"
  DEV_URL = "localhost:3000"
 
  def welcome_email(user)
    @user = user

    @url =  confirm_email_url(host: if Rails.env.production?
                                      PROD_URL
                                    else
                                      DEV_URL
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

  def first_pt_msg(email)
    @email = email
    @body = get_first_part(@email)
    @sender = User.find_by_email(@email.from)

    @see_more_url = user_email_url(user_id: @sender.id,
                                  id: email.id,
                                  host: (Rails.env.production? ? PROD_URL : DEV_URL),
                                  protocol: Rails.env.production? ? 'https' : 'http'
                                 )
    mail(from: email.from, 
         to: email.to, 
         subject: email.subject)
  end

  private 


  def get_first_part(email)
    first_pt_regex = /(^.*)#{MORE_INDICATOR}/m
    match = first_pt_regex.match(email.body)
    $1
  end
end
