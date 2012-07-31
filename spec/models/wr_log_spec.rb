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
#  responded        :boolean
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  token_identifier :string(255)
#

require 'spec_helper'

describe WrLog do
  let(:sender) { FactoryGirl.create(:user) }
  let(:receiver) { FactoryGirl.create(:user) }
  let(:email) { Email.create(to:receiver.email, from:sender.email, subject: "Subject", body: "Body") }
  let(:wr_log) { email.wr_logs.create(action: "email", sender_id: User.find_by_email(email.from).id,
                 receiver_id: User.find_by_email(email.to).id, email_part:0, responded: false) }

  subject { wr_log }

  it { should be_valid }

  describe "wr_log methods" do
    it { should respond_to(:action) }
    it { should respond_to(:sender_id) }
    it { should respond_to(:receiver_id) }
    it { should respond_to(:email_id) }
    it { should respond_to(:email_part) }
    it { should respond_to(:responded) }
    it { should respond_to(:token_identifier)}
    its(:email_id) { should == email.id }
    its(:action) { should == "email" }  # How do I says "or 'more'"?
  end

end
