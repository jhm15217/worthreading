# == Schema Information
#
# Table name: wr_logs
#
#  id          :integer         not null, primary key
#  action      :string(255)
#  sender_id   :integer
#  receiver_id :integer
#  email_id    :integer
#  email_part  :integer
#  responded   :boolean
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class WrLog < ActiveRecord::Base
  attr_accessible :action, :email_id, :email_part, :receiver_id, :responded, :sender_id
  belongs_to :email
  belongs_to :user
end
