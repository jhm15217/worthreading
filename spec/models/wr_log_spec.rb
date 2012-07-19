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

require 'spec_helper'

describe WrLog do
  pending "add some examples to (or delete) #{__FILE__}"
end
