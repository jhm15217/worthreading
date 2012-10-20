require 'spec_helper'


describe WrLogsHelper do
  let (:email1) { FactoryGirl.create(:email) }
  let (:email2) { FactoryGirl.create(:email) }
  let (:sender1) { FactoryGirl.create(:user) }
  let (:sender2) { FactoryGirl.create(:user) }
  let (:receiver1) { FactoryGirl.create(:user) }
  let (:receiver2) { FactoryGirl.create(:user) }
  let(:wr_log1) { FactoryGirl.create(:wr_log) }
  let(:wr_log2) { FactoryGirl.create(:wr_log) }
  before do
    wr_log1.email_id = email1.id
    wr_log1.receiver_id = receiver1.id
    wr_log1.sender_id = sender1.id
    wr_log1.forwarded  = Time.now
    wr_log1.save
    wr_log2.email_id = email2.id
    wr_log2.receiver_id = receiver2.id
    wr_log2.sender_id = sender2.id
    wr_log2.save
  end
  it "should produce sorted array" do
    helper.best_recent_emails.map{|x| x.email_id}.should == [wr_log1.email_id, wr_log2.email_id]
  end
end

