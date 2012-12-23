require 'emails_helper'
# == Schema Information
#
# Table name: emails
#
#  id         :integer         not null, primary key
#  from       :string(255)
#  to         :text
#  subject    :string(255)
#  body       :text
#  parts      :text            yaml
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  user_id    :integer
#



class Email < ActiveRecord::Base
  attr_accessible :body, :from, :to, :subject, :parts
  belongs_to :user
  has_many :wr_logs, dependent: :destroy
  serialize :parts

  before_save { |email|
    email.from = from.downcase
    email.to = to.downcase
  }

  def self.find_or_register(email_address)
    User.where(email: email_address.downcase).
        first_or_create!(name:"Unknown",
                         password:"Unknown",
                         password_confirmation:"Unknown",
                         email_notify: true)
  rescue
    nil
  end

  # Takes an email and generates messages for every person on the address list
  # If one of the "persons" is "subscribers@worth-reading.com", then a list is included in the list
  # email_address_list(to)[1] is a list of malformed email addresses that will be ignored. Someday, it should
  # be reported somehow.
  def process(sender)
    @sender = sender
    process_helper(email_address_list(to)[0].map{|a| a[:email]})
  end

  def process_helper(alist)
    if alist == []
      []
    else
      address = alist.first
      mail_list =
          (if address == "subscribers@worth-reading.org"
             if @sender.subscribers.empty?
               error = "There are no subscribers on your list. Please add subscribers to your list"
               [ UserMailer.error_email(error, @sender, self) ]
               #UserMailer.delay.send_error(error, sender, self)
             else
               process_helper(@sender.subscribers.map{|receiver| receiver.email})
             end
           elsif address.match('@worth-reading.org')
             puts "Ignore #{address} to avoid forwarding loop."
             [] # log this somehow
           else # It's an individual
             [ UserMailer.send_msg(@sender, Email.find_or_register(address), self) ]
           end)
      mail_list + process_helper(alist[1..-1])
    end
  rescue  "Maximum exceeded"
    []
  end

  def deliver_all(list)
    list.each do |item|
        item.deliver
      end
  end

  # @param [String] email_addresses
  # returns a 2-array [good, bad] of email addresses, bad being malformed addresses
  def email_address_list(email_addresses)
    result = []
    until !email_addresses
      if x = email_addresses.match('\s*("[^"]*"[^,]*|\s*[^,]*)(,(.*)|\s*)')
        result = result + [x.captures[0]]
        email_addresses = x.captures[2]
      else
        email_addresses = nil
      end
    end
    t = result.zip(result.map{|x| email_address_parts(x) })
    [ t.select{|x,y| y}.map{|p| p[1]}, t.select{|x,y| !y  }.map{|p| p[0]}]
  end

  VALID_EMAIL_REGEX = /^[_a-z0-9+\-]+(\.[_a-z0-9+\-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/i

  # Captures formats:
  # "John Doe"<johndoe@example.com>, John Doe<johndoe@example.com>, johndoe@example.com
  def email_address_parts(email_address)
    if parts = (email_address.match('"([^"]*)"\s*<(.*)>') or email_address.match('([a-zA-Z\s.]*)<(.*)>'))
      name = parts.captures[0]
      email_address = parts.captures[1]
    else
      name = ""
    end
    if email_address.match(VALID_EMAIL_REGEX)
      { name: name.strip, email: email_address.strip }
    else
      nil
    end
  end

  # Email stats
  def num_times_opened
    self.wr_logs.where("action = 'opened'").count + self.num_times_liked
  end

  def num_times_liked
    self.wr_logs.where("action = 'worth reading'").count
  end

  default_scope order: 'emails.created_at DESC'

  validates :from, presence: true
  #  ,format: { with: VALID_EMAIL_REGEX }
  validates :to, presence: true
  #  ,format: { with: VALID_EMAI_REGEX }
end
