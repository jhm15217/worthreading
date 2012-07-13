# == Schema Information
#
# Table name: relationships
#
#  id            :integer         not null, primary key
#  follower_id   :integer
#  followed_id   :integer
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  subscriber_id :integer
#  subscribed_id :integer
#

class Relationship < ActiveRecord::Base
  attr_accessible :subscriber_id

  belongs_to :subscriber, class_name: "User"
  belongs_to :subscribed, class_name: "User"


  validates :subscriber_id, presence: true
  validates :subscribed_id, presence: true
end
