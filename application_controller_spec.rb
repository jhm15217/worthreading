require 'spec_helper'
require 'application_controller'

describe ApplicationController do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:email) { FactoryGirl.create(:email) }
  let(:wr_log) { FactoryGirl.create(:wr_log) }

  before do  
    user.add_subscriber!(other_user)
  end

  describe "Sending a more-free message" do
    let(:body)  { %Q{Hello world! Have to check the correct information is 
                     captured before.} }
    let(:ac) { ApplicationController.new }

    before do  
      email.from = user.email
      email.to = other_user.email
      email.body = body
      email.save

      wr_log.sender_id = user.id
      wr_log.receiver_id = other_user.id
      wr_log.email_id = email.id
      wr_log.save
    end

    it "should render the message successfully" do 
      lambda { ac.instance_eval{display_message(email, wr_log, other_user) }}.should_not raise_error
    end
    
    it "should have a Worth Reading link" do
      ApplicationController.display_message(email, wr_log, other_user).body.encoded.should match(/Worth Reading/m)
    end

    it "should have the correct link for the Worth Reading link" do
      ApplicationController.display_message(email, wr_log, other_user).body.
        encoded.should include(
          "http://localhost:3000/wr_logs/#{wr_log.id}?"\
          "token_identifier=#{wr_log.token_identifier}&amp;worth_reading=1")
    end

    it "should have a web beacon" do
      ApplicationController.display_message(email, wr_log, other_user).body.encoded.
        should include("<img alt=\"\" src=\"http:\/\/localhost:3000/wr_logs/#{wr_log.id}/msg_opened/#{wr_log.token_identifier}\" />")
    end

    context "when there is a text email signature" do
      before { email.body = email.body + "----- Forwarded message ----\n-- \n John Doe" and email.save }
      it "should parse out a signature correctly and insert worth reading link in appropriate place" do
        ApplicationController.display_message(email, wr_log, other_user).body.encoded.
          should match(/Forwarded message.*<div class='signature'>/m)
      end
    end

    context "when there is an html email signature" do 
      before do 
        email.body = "The top story has some compelling graphs. Too bad 
          most voters are not persuaded by graphs.<br><br><div class=\"gmail_quote\">
          ---------- Forwarded message ----------<br>From: -- <br>John Doe" 
        email.save
      end
      it "should parse out a signature correctly and insert worth reading link in appropriate place" do
        ApplicationController.display_message(email, wr_log, other_user).body.encoded.
          should match(/Forwarded message.*<div class='signature'>/m)
      end
    end

    it "should deliver successfully" do
      lambda { ApplicationController.display_message(email, wr_log, other_user).deliver }.should_not raise_error
    end
  end

  describe "Sending a message with a <more>" do
    let(:body)  { %Q{Hello world! Have to check the correct information is 
                     captured before.<more>Rest of Message.} }

    before do  
      email.from = user.email
      email.to = other_user.email
      email.body = body
      email.save

      wr_log.sender_id = user.id
      wr_log.receiver_id = other_user.id
      wr_log.email_id = email.id
      wr_log.save
    end

    it "should render the message successfully" do 
      lambda { ApplicationController.display_message(email, wr_log, other_user) }.should_not raise_error
    end
    
    it "should have a More link" do
      ApplicationController.display_message(email, wr_log, other_user).body.encoded.should match(/More/m)
    end

    it "should have a web beacon" do
      ApplicationController.display_message(email, wr_log, other_user).body.encoded.
        should include("<img alt=\"\" src=\"http:\/\/localhost:3000/wr_logs/#{wr_log.id}/msg_opened/#{wr_log.token_identifier}\" />")
    end

    it "should deliver successfully" do
      lambda { ApplicationController.display_message(email, wr_log, other_user).deliver }.should_not raise_error
    end
  end


  describe "email_address_parts" do
    it "handles unquoted names" do
      email_address_parts("Jim<jim@email.com>") == { name: "Jim", email: "jim@email.com" }
    end
    it "handles quoted names" do
      email_address_parts('"Jim Jones"<jim@email.com>') == { name: "Jim Jones", email: "jim@email.com" }
    end
    it "handles no name" do
      email_address_parts("jim@email.com") == { name: "", email: "jim@email.com" }
    end
    it "handles error" do
      email_address_parts("Jim<jimemail.com>") == nil
    end
  end

  describe "email_address_list" do
    it "handles singleton" do
      email_address_list("Jim<jim@email.com>") == []
    end
    it "handles two names" do
      email_address_list('"Jim Jones"<jim@email.com>,Jim<jim@email.com>') == [{ name: "Jim Jones", email: "jim@email.com" },{ name: "Jim", email: "jim@email.com" }]
    end
    it "handles error" do
      email_address_list("Jim<jimemail.com>") == []
    end
  end
end