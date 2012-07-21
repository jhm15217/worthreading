# == Schema Information
#
# Table name: emails
#
#  id         :integer         not null, primary key
#  from       :string(255)
#  to         :string(255)
#  subject    :string(255)
#  body       :text
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  user_id    :integer
#

class Email < ActiveRecord::Base
  attr_accessible :body, :from, :to, :subject
  belongs_to :user
  has_many :wr_logs
  
  before_save { |email| 
    email.from = from.downcase
    email.to = to.downcase
  }

  default_scope order: 'emails.created_at DESC'

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :from, presence: true,
    format: { with: VALID_EMAIL_REGEX }
  validates :to, presence: true,
    format: { with: VALID_EMAIL_REGEX }
  validates :body, presence: true
end
