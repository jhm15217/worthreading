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
#

require 'spec_helper'

describe Email do
  pending "We will fill in later"
end
