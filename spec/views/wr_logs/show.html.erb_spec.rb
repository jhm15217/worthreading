require 'spec_helper'

describe "wr_logs/show" do
  let(:sender) { FactoryGirl.create(:user)}
  let(:receiver) { FactoryGirl.create(:user)}
  let(:email) { FactoryGirl.create(:email)}
  let(:wr_log) { FactoryGirl.create(:wr_log)}
  before(:each) do
    wr_log.sender_id = sender.id
    wr_log.receiver_id = receiver.id
    wr_log.email_id = email.id
    wr_log.save
    @wr_log = wr_log
    @email = email
    @sender = sender
    @receiver = receiver
  end

  it "renders attributes in <p>" do
    render
  end
end
