class WrLog < ActiveRecord::Base
  attr_accessible :action, :email_id, :email_part, :receiver_id, :responded, :sender_id
end
