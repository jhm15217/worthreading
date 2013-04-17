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
#  forward    :datetime
#

require 'spec_helper'

  describe WrLog do
    let(:sender) { FactoryGirl.create(:user) }
    let(:receiver) { FactoryGirl.create(:user) }
    let(:email) { FactoryGirl.create(:email) }
    let(:wr_log) { FactoryGirl.create(:wr_log) }

    before do
      email.body = "....http://www.cs.cmu.edu......"
      email.parts = [email.body]
      email.save
      email.reload
      wr_log.sender_id = sender.id
      wr_log.receiver_id = receiver.id
      wr_log.email_id = email.id
      wr_log.email_part = 0
      wr_log.save
      sender.add_subscriber(receiver)
    end

    subject { wr_log }

    it { should be_valid }

    describe "wr_log methods" do
      it { should respond_to(:action) }
      it { should respond_to(:sender_id) }
      it { should respond_to(:receiver_id) }
      it { should respond_to(:email_id) }
      it { should respond_to(:email_part) }
      it { should respond_to(:opened) }
      it { should respond_to(:followed_url) }
      it { should respond_to(:forwarded) }
      it { should respond_to(:token_identifier) }
      its(:email_id) { should == email.id }
      its(:action) { should == "email" } # How do I says "or 'more'"?
    end

    describe "abstract_message" do
      it "should store url in wr_log" do
        expect { wr_log.abstract_message }.to change { wr_log.url }.to("http://www.cs.cmu.edu")
      end
      it "should replace url" do
        wr_log.abstract_message[:body].should match "....http://localhost:3000/wr_logs/1/follow"
      end
    end

  end
