# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  name                   :string(255)
#  email                  :string(255)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  password_digest        :string(255)
#  remember_token         :string(255)
#  admin                  :boolean         default(FALSE)
#  likes                  :integer
#  confirmed              :boolean         default(FALSE)
#  confirmation_token     :string(255)
#  password_reset_sent_at :datetime
#  first_login_at         :datetime
#  email_notify           :boolean         default(TRUE)
#  cohort                 :integer         default(0)
#

class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation, :email_notify, :forward
  has_secure_password
  has_many :emails, dependent: :destroy

  # Relationship Associations
  has_many :relationships, foreign_key: "subscribed_id", dependent: :destroy
  has_many :subscribers, through: :relationships
  has_many :reverse_relationships, foreign_key: "subscriber_id", 
    class_name: "Relationship", dependent: :destroy
  has_many :subscribed_users, through: :reverse_relationships, source: :subscribed
  has_many :receiver_wr_logs, foreign_key: "receiver_id", class_name: "WrLog", dependent: :destroy

  # WrLog Associations
  has_many :sender_wr_logs, class_name: "WrLog", foreign_key: "sender_id"

  def feed
  end

  # Like Incrementor Methods
  def incr_decr_likes(user_who_likes, incr_by, decr_by)
    self.increment!(:likes, incr_by)
    user_who_likes.decrement!(:likes, decr_by)
  end

  # Subscriber Methods
  def add_subscriber(subscriber)
    self.relationships.create(subscriber_id: subscriber.id)
  end

  def add_subscriber!(subscriber)
    self.relationships.create!(subscriber_id: subscriber.id)
  end

  def subscribed_by?(subscriber)
    self.relationships.find_by_subscriber_id(subscriber.id)
  end
  
  def rem_subscriber!(subscriber)
    self.relationships.find_by_subscriber_id(subscriber.id).destroy
  end

  def rem_subscribed!(subscribed)
    self.reverse_relationships.find_by_subscribed_id(subscribed.id).destroy
  end

  def send_msg_to_subscribers(email)
    self.subscribers.each do |subscriber|
      wr_log = email.wr_logs.create do |log|
        log.action = "email"
        log.sender_id = self.id
        log.receiver_id = subscriber.id 
        log.emailed = Time.now
      end
      UserMailer.send_message(email, wr_log, subscriber).deliver
    end
  end

  def send_msg_to_individual(email, receiver)
    wr_log = email.wr_logs.create do |log|
      log.action = "email"
      log.sender_id = self.id
      log.receiver_id = receiver.id 
      log.emailed = Time.now
    end
    self.add_subscriber(receiver) unless self.subscribed_by?(receiver)  #May already be subscribed
    UserMailer.send_message(email, wr_log, receiver).deliver
  end

  # The confirmation token used to confirm emails when creating a user is also
  # used to send and confirm the password reset link
  # The time the email is sent is recorded to help establish a 1 hour expiration rule
  # on the email
  def send_password_reset
    generate_confirmation_token
    self.password_reset_sent_at = Time.now
    save!(validate: false)

    UserMailer.password_reset(self).deliver
  end

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64
  end

  # Active Record Callbacks
  before_save { |user| 
    user.email = email.downcase
    if user.new_record? 
      user.likes = 50
      user.generate_confirmation_token
    end
  }
  before_save :create_remember_token

  private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

  # Validataions
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})\z/i
  validates :email, presence:   true,
    format:     { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 } 
  validates :password_confirmation, presence: true
end
