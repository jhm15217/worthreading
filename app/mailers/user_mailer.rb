class UserMailer < ActionMailer::Base
  default from: "notifications@worth-reading.org"

  # Constants
#  MORE_INDICATOR = "<more>"
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

  def send_message(email)
    @email = email

    @body = @email.body

    @sender = User.find_by_email(@email.from)

    @worth_reading_url = wr_log_url(action: "worth reading",
                                  id: WrLog.find_by_sender_id(@sender.id),
                                  host: Rails.env.production? ? PROD_URL : DEV_URL,
                                  protocol: Rails.env.production? ? 'https' : 'http')
    mail(from: email.from, to: email.to, subject: email.subject)
  end

  def alert_change_in_wr_log(wr_log)
    @wr_log = wr_log
    @sender = User.find_by_id(@wr_log.sender_id)
    @recipient = User.find_by_id(@wr_log.receiver_id)
    mail(to: @sender.email, subject: "#{@recipient.email} found your email worth reading") 
  end

# NOTE Unimplemented for now but possible use in the future
# Implementationg for parsing out an email with more than one more button
# Utilizes regex to capture everything before the first more button and sends 
# out that first part in an email
#  def first_pt_msg(email)
#    @email = email
#
#    @body = get_first_part(@email)  
#
#    @sender = User.find_by_email(@email.from)
#
#    @see_more_url = user_email_url(user_id: @sender.id,
#                                  id: email.id,
#                                  host: (Rails.env.production? ? PROD_URL : DEV_URL),
#                                  protocol: Rails.env.production? ? 'https' : 'http')
#    mail(from: email.from, 
#         to: email.to, 
#         subject: email.subject)
#  end

  private 

#  Method for parsing out a more button 
#  def get_first_part(email)
#    first_pt_regex = /(^.*)#{MORE_INDICATOR}/m
#    if match = first_pt_regex.match(email.body)
#      $1
#    else
#      email.body
#    end
#  end
end
