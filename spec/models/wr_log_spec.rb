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

require 'spec_helper'

describe WrLog do
  let(:sender) { FactoryGirl.create(:user) }
  let(:receiver) { FactoryGirl.create(:user) }
  let(:email) { FactoryGirl.create(:email) }
  let(:wr_log) { FactoryGirl.create(:wr_log) }

  before do
    wr_log.sender_id = sender.id
    wr_log.receiver_id = receiver.id
    wr_log.email_id = email.id
    wr_log.save
    wr_log.reload
  end

  subject { wr_log }

  it { should be_valid }

  describe "wr_log methods" do
    it { should respond_to(:action) }
    it { should respond_to(:sender_id) }
    it { should respond_to(:receiver_id) }
    it { should respond_to(:email_id) }
    it { should respond_to(:email_part) }
    it { should respond_to(:token_identifier)}
    its(:email_id) { should == email.id }
    its(:action) { should == "email" }  # How do I says "or 'more'"?
  end

end
