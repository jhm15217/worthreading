# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  password_digest    :string(255)
#  remember_token     :string(255)
#  admin              :boolean         default(FALSE)
#  likes              :integer
#  confirmed          :boolean         default(FALSE)
#  confirmation_token :string(255)
#

class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation
  has_secure_password
  has_many :emails, dependent: :destroy

  # Relationship Associations
  has_many :relationships, foreign_key: "subscribed_id", dependent: :destroy
  has_many :subscribers, through: :relationships
  has_many :reverse_relationships, foreign_key: "subscriber_id", 
    class_name: "Relationship", dependent: :destroy
  has_many :subscribed_users, through: :reverse_relationships, source: :subscribed

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
  def add_subscriber!(subscriber) 
    self.relationships.create!(subscriber_id: subscriber.id)
  end

  def subscribed_by?(subscriber)
    self.relationships.find_by_subscriber_id(subscriber.id)
  end
  
  def rem_subscriber!(subscriber)
    self.relationships.find_by_subscriber_id(subscriber.id).destroy
  end

  # Active Record Callbacks
  before_save { |user| 
    user.email = email.downcase
    if user.new_record? 
      user.likes = 50 
      user.confirmation_token = SecureRandom.urlsafe_base64
    end
  }
  before_save :create_remember_token

  private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

  # Validataions
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
    format:     { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 } 
  validates :password_confirmation, presence: true
end
