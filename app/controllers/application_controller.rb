class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include UsersHelper
  include EmailsHelper
  include WrLogsHelper

  # default_settings for WillPaginate
  WillPaginate.per_page = 15
  
  PROD_URL = "www.worth-reading.org"
  DEV_URL = "localhost:3000"
  PROTOCOL = 'http'
  
  #  Method for parsing out a more button 
  def get_nth_part(body, n)
    next_pt_regex =  /(.*?)(&lt;more&gt;|'<more>')(.*)/m
    while n > 0
      if next_pt_regex.match(body)
        n = n - 1
        body = $3
      else
        return nil
      end
    end
    $1
  end

  def send_msg_to_individual(sender, receiver, email)
    wr_log = email.wr_logs.create! do |log|
      log.action = "email"
      log.sender_id = sender.id
      log.receiver_id = receiver.id 
      log.emailed = Time.now
    end
    sender.add_subscriber(receiver) unless sender.subscribed_by?(receiver)  #May already be subscribed

	  display_message(wr_log, 1).deliver
  end

  # Having created the wr_log entry, we send it out with urls pointing to our
  # follow-up web pages
  def display_message(wr_log, part_number)

    @email = Email.find(wr_log.email_id)
    @body = @email.body
    @sender = User.find(wr_log.sender_id)
    @receiver = User.find(wr_log.receiver_id)
    @relationship = Relationship.where(subscriber_id: wr_log.receiver.id, 
                                       subscribed_id: wr_log.sender.id).first

     if @part = get_nth_part(@body, part_number)  #another <more> in the email
      @see_more_url = wr_log_url(more: part_number.to_s,
                              id: id,
                              token_identifier: token_identifier, 
                              host: (Rails.env.production? ? PROD_URL : DEV_URL),
                              protocol: Rails.env.production? ? 'https' : 'http')
    else # There is no <more>, 
      # Parsing the email signature
      if capture = @body.match(/(-- <br>.*)/m) || @body.match(/(^-- \n.*)/m)
        @signature = capture[0]
        @body = @body.gsub(/#{@signature}/m, "")
      end
      
      @worth_img_url = "#{PROTOCOL}://#{PROD_URL}/assets/worth_reading_button2.png"
      @worth_reading_url = wr_log_url(worth_reading: "1",
                                    id: wr_log.id,
                                    token_identifier: wr_log.token_identifier, 
                                    host: Rails.env.production? ? PROD_URL : DEV_URL,
                                    protocol: PROTOCOL)
      @whats_this_url = whats_this_url(id: wr_log.id, 
                                     token_identifier: wr_log.token_identifier,
                                     host: Rails.env.production? ? PROD_URL : DEV_URL,
                                     protocol: PROTOCOL) 
      @unsubscribe_url = email_unsubscribe_relationship_url(id: @relationship.id, 
                                 token_identifier: @relationship.token_identifier, 
                                 host: Rails.env.production? ? PROD_URL : DEV_URL, 
                                 protocol: PROTOCOL)
    end

    if part_number == 1
      @beacon_url = msg_opened_url(id: wr_log.id, 
                               token_identifier: wr_log.token_identifier, 
                               host: Rails.env.production? ? PROD_URL : DEV_URL, 
                               protocol: PROTOCOL)
      UserMailer.show(wr_log, @part, @see_more_url, @signature,@body,@worth_img_url, @worth_reading_url, @whats_this_url, @unsubscribe_url, @beacon_url)
    end
  end


end
