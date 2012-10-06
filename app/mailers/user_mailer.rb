require 'wr_logs_helper'

class UserMailer < ActionMailer::Base
  PROD_URL = "www.worth-reading.org"
  DEV_URL = "localhost:3000"
  PROTOCOL = 'http'

  default from: "notifications@worth-reading.org"
  #ActionMailer::Base.raise_delivery_errors = false  # until I figure out how to catch

  # Constants
  AUTOGEN_MSG = "This is an autogenerated email from worth-reading.org. 
                 There is no need to reply to this email."
  def welcome_email(user)
    @user = user

    @url =  confirm_email_url(host: if Rails.env.production?
                                      PROD_URL
                                    else
                                      DEV_URL
                                    end,
                               id: user.id, 
                               confirmation_token: user.confirmation_token,
                               protocol: "http" )
    mail(to: user.email, subject: "Welcome to Worth Reading")
  end

  # Check if email taken
  def confirm_email_change(user, new_email)
    @user = user
    @new_email = new_email
    @autogen_msg = AUTOGEN_MSG

    @change_email_url = confirm_email_change_user_url(id: @user.id,
                                    confirmation_token: @user.confirmation_token,
                                    new_email: new_email,
                                    host: Rails.env.production? ? PROD_URL : DEV_URL,
                                    protocol: "http")
    mail(to: @new_email, subject: "Confirm Change in Email Address")
  end

  def alert_change_in_wr_log(wr_log)
    @wr_log = wr_log
    @email = Email.find(@wr_log.email_id)
    @sender = User.find_by_id(@wr_log.sender_id)
    @recipient = User.find_by_id(@wr_log.receiver_id)
    @autogen_msg = AUTOGEN_MSG

    if @sender[:email_notify]
      case @wr_log.action
        when "worth reading"
          @alert = "liked your email"
        when "opened"
          @alert = "opened your email"
        when "more"
          @alert = "turned a page"
        else
          raise "Invalid action"
      end

      begin
        mail(to: @sender.email, subject: "#{@recipient.email}, #{@alert}: #{@email.subject}").deliver
      rescue Exception
        flash.now[:error] = "Could not save client"
        render :action => "new"
      end
    end
  end

def send_msg(sender, receiver, email)
    wr_log = email.wr_logs.create! do |log|
      log.action = "email"
      log.sender_id = sender.id
      log.receiver_id = receiver.id
      log.email_id = email.id
      log.email_part = 0
      log.emailed = Time.now
    end
    sender.add_subscriber(receiver) unless sender.subscribed_by?(receiver)  #May already be subscribed

    @beacon_url = msg_opened_url(id: wr_log.id,
                             token_identifier: wr_log.token_identifier,
                             host: Rails.env.production? ? PROD_URL : DEV_URL,
                             protocol: PROTOCOL)
	  @message = wr_log.abstract_message
	  mail(to: User.find(wr_log.receiver_id).email, from: User.find(wr_log.sender_id).email, subject: Email.find(wr_log.email_id).subject)
  end

  def error_email(error, user, email)
    @sender = user
    @error = error
    @email = email
    @autogen_msg = AUTOGEN_MSG
    @signin_url = signin_url(protocol: "http", host: Rails.env.production? ? PROD_URL : DEV_URL)

    mail(to: @sender.email, subject: "Error: #@error")
  end

  def password_reset(user)
    @user = user
    @autogen_msg = AUTOGEN_MSG

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

end
