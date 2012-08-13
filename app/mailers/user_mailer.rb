class UserMailer < ActionMailer::Base
  default from: "notifications@worth-reading.org"

  # Constants
  PROD_URL = "www.worth-reading.org"
  DEV_URL = "localhost:3000"
  PROTOCOL = 'http'
#  MORE_INDICATOR = "<more>"
 
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

  def send_message(email, wr_log, recipient)
    @email = email
    @body = @email.body
    @wr_log =  wr_log
    @sender = User.find_by_email(@email.from)

    @worth_reading_url = wr_log_url(action: "worth reading",
                                  id: WrLog.find_by_sender_id(@sender.id),
                                  host: Rails.env.production? ? PROD_URL : DEV_URL,
                                  protocol: PROTOCOL )
    @beacon_url = msg_opened_url(id: @wr_log.id, 
                                 token_identifier: @wr_log.token_identifier, 
                                 host: Rails.env.production? ? PROD_URL : DEV_URL, 
                                 protocol: PROTOCOL)
    mail(from: email.from, to: recipient.email, subject: email.subject)
  end

  def alert_change_in_wr_log(wr_log)
    @wr_log = wr_log
    @sender = User.find_by_id(@wr_log.sender_id)
    @recipient = User.find_by_id(@wr_log.receiver_id)

    case @wr_log.action
    when "worth reading"
      @alert = "found your email worth reading"
    when "opened"
      @alert = "opened your email"
    else
      raise "Invalid action"
    end

    mail(to: @sender.email, subject: "#{@recipient.email}, #{@alert}")
  end

  def error_email(error, user, email)
    @sender = user
    @error = error
    @email = email
    @signin_url = signin_url(protocol: PROTOCOL, host: Rails.env.production? ? PROD_URL : DEV_URL)

    mail(to: @sender.email, subject: "Error: #@error")
  end

  def password_reset(user)
    @user = user

    @url =  reset_password_url(host: if Rails.env.production?
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
    mail(to: user.email, subject: "Request for Password Reset")
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
