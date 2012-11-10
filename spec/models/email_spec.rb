# == Schema Information
#
# Table name: emails
#
#  id         :integer         not null, primary key
#  from       :string(255)
#  to         :string(255)
#  subject    :string(255)
#  body       :text
#  parts      :string           yaml
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  user_id    :integer
#

require 'spec_helper'

describe Email do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:wr_log) { FactoryGirl.create(:wr_log) }

  describe "more-free email"
    let (:body) { "no more" }
    before do  
      user.add_subscriber!(other_user)
      @email = user.emails.build(to: "subscribers@worth-reading.org",
                                      from: user.email,
                                      subject: "Lorem Ipsum", 
                                      body: body,
                                      parts: body.split('<more>'))
   end

    subject { @email }
    it { should respond_to(:to) }
    it { should respond_to(:from) }
    it { should respond_to(:subject) }
    it { should respond_to(:body) }
    it { should respond_to(:user_id) }
    it { should respond_to(:parts) }
    its(:user) { should == user } 
    it { should be_valid }

    describe "when a sender is not present" do 
      before { @email.to = " " }
      it { should_not be_valid }
    end

    describe "when a recipient is not present" do
      before { @email.from = " " }
      it { should_not be_valid }
    end

#    describe "when an email is invalid" do
#      let(:addresses) {%w[user@foo,com user_at_foo.org example.user@foo.
#        foo@bar_baz.com foo@bar+baz.com]}
#      context "for the sender" do
#        it "should not be valid" do
#          addresses.each do |invalid_address|
#            @email.to = invalid_address
#            @email.should_not be_valid
#          end
#        end
#      end
#
#      context "for the recipient" do
#        it "should not be valid" do
#          addresses.each do |invalid_address|
#            @email.to = invalid_address
#            @email.should_not be_valid
#          end
#        end
#      end
#    end

    describe "accessible attributes" do
      it "should not allow access to user_id" do
        expect do
          Email.new(user_id: user.id)
        end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      end    
    end

  describe "Sending a more-free message" do
    let(:body)  { %Q{More-free message./n} }
    before do
      @email.body = body
      @email.parts = [body]
      @email.save
    end

    it "should render the message successfully" do
      lambda { @email.process(user) }.should_not raise_error
    end

    it "should have a Forward Email link" do
      @email.process(user)[0].body.encoded.should match(/Email/m)
    end

    it "should have the correct link for the forwarding link" do
      @email.process(user)[0].body.
          encoded.should match("wr_logs.*forward=1.*token_identifier=.*")
    end

    it "should have a web beacon" do
      @email.process(user)[0].body.encoded.
          should match("<img alt=\"\" src=\"http:\/\/localhost:3000/wr_logs/.*/msg_opened/.*\" />")
    end


    it "should deliver successfully" do
      lambda { @email.process(user)[0].deliver }.should_not raise_error
    end
  end

  describe "sending a message to all subscribers" do
    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:user3) { FactoryGirl.create(:user) }
    let(:user4) { FactoryGirl.create(:user) }
    let(:email) { FactoryGirl.create(:email) }

    before do
      body = %Q{More-free message./n}
      @email = user.emails.create!(to: "subscribers@worth-reading.org",
                                      from: user1.email,
                                      subject: "Lorem Ipsum", 
                                      body: body,
                                      parts: body.split("<more>"))

      user1.add_subscriber!(user2)
      user1.add_subscriber!(user3)
      user1.add_subscriber!(user4)
    end

    it "should send a message to all subscribers" do
      expect { @email.deliver_all(@email.process(user1)) }.
        to change(ActionMailer::Base.deliveries, :size).by(3)
    end

    it "should create a wr_log for each subscriber associated with message" do
      expect { @email.deliver_all(@email.process(user1)) }.
        to change(WrLog, :count).by(3)
    end
  end

  describe "Sending a message with a <more>" do
    let(:body)  { %Q{/Beginnging of Message<more>Rest of Message.} }

    before do  
      @email = user.emails.create!(to: "subscribers@worth-reading.org",
                                      from: user.email,
                                      subject: "Lorem Ipsum", 
                                      body: body,
                                      parts: body.split("<more>"))
    end

    it "should render the message successfully" do 
      lambda { @email.process(user) }.should_not raise_error
    end

    it "should not have whole message" do
      @email.process(user)[0].body.encoded.should_not match(/Rest of Message./m)
    end

    it "should have a More url" do
      @email.process(user)[0].body.encoded.
        should match(/<div class='more-button'>.*wr_logs\/.*more\=.*/m)
    end

    it "should deliver successfully" do
      lambda { @email.process(user)[0].deliver }.should_not raise_error
    end
  end


  describe "utility methods"
    let(:body)  { "" }

    before do  
      @email = user.emails.create!(to: "subscribers@worth-reading.org",
                                    from: user.email,
                                    subject: "Just to have an instance",
                                    body: body,
                                    parts: body.split("<more>"))
    end
    describe "email_address_parts" do
      it "handles unquoted names" do
        @email.email_address_parts("Jim<jim@email.com>") == { name: "Jim", email: "jim@email.com" }
      end
      it "handles quoted names" do
        @email.email_address_parts('"Jim Jones"<jim@email.com>') == { name: "Jim Jones", email: "jim@email.com" }
      end
      it "handles no name" do
        @email.email_address_parts("jim@email.com") == { name: "", email: "jim@email.com" }
      end
      it "handles error" do
        @email.email_address_parts("Jim<jimemail.com>") == nil
      end
    end


  describe "email_address_list" do
    it "handles singleton" do
      @email.email_address_list("Jim<jim@email.com>") == []
    end
    it "handles two names" do
      @email.email_address_list('"Jim Jones"<jim@email.com>,Jim<jim@email.com>') == [{ name: "Jim Jones", email: "jim@email.com" },{ name: "Jim", email: "jim@email.com" }]
    end
    it "handles error" do
      @email.email_address_list("Jim<jimemail.com>") == []
    end
  end
  
end
