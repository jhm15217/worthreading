# == Schema Information
#
# Table name: wr_logs
#
#  id               :integer         not null, primary key
#  action           :string(255)
#  sender_id        :integer
#  receiver_id      :integer
#  email_id         :integer
#  email_part       :integer
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  token_identifier :string(255)
#  emailed          :datetime
#  opened           :datetime
#  worth_reading    :datetime
#

class WrLog < ActiveRecord::Base
  attr_accessible :action, :email_id, :email_part, :receiver_id, :responded, :sender_id
  belongs_to :email
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  before_create :create_token_identifier

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

 private
  def create_token_identifier
    self.token_identifier = SecureRandom.urlsafe_base64
  end
  # Validataions
  validates :sender_id, presence: true
  validates :email_id, presence:   true
  validates :receiver_id, presence:   true  
end
