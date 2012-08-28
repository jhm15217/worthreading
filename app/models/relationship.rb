# == Schema Information
#
# Table name: relationships
#
#  id               :integer         not null, primary key
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  subscriber_id    :integer
#  subscribed_id    :integer
#  token_identifier :string(255)
#

class Relationship < ActiveRecord::Base
  before_save :create_token_identifer 

  attr_accessible :subscriber_id

  belongs_to :subscriber, class_name: "User"
  belongs_to :subscribed, class_name: "User"


  validates :subscriber_id, presence: true
  validates :subscribed_id, presence: true

  private 
  def create_token_identifer
    self.token_identifier = SecureRandom.urlsafe_base64
  end
end
