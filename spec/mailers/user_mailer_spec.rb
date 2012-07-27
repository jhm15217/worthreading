require "spec_helper"

describe UserMailer do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:email) { FactoryGirl.create(:email) }
  let(:wr_log) { FactoryGirl.create(:wr_log) }
  let(:body)  { %Q{Hello world! Have to check the correct information is 
                   captured before.\n <more>\n This is more information after 
                   the more button. } }

  before do  
    email.from = user.email
    email.body = body
    email.save

    wr_log.sender_id = user.id
    wr_log.receiver_id = other_user.id
    wr_log.save
  end

  describe "Welcome Email/Confirmation Email" do 
    it "should render the welcome email successfully" do 
      lambda { UserMailer.welcome_email(user) }.should_not raise_error
    end

    it "should deliver successfully" do
      lambda { UserMailer.welcome_email(user).deliver }.should_not raise_error
    end
  end

  describe "Sending a message" do
    it "should render the message successfully" do 
      lambda { UserMailer.send_message(email) }.should_not raise_error
    end
    
    it "should have a Worth Reading link" do
      UserMailer.send_message(email).body.encoded.should match(/Worth Reading/m)
    end

    it "should have the correct link for the Worth Reading link" do
      UserMailer.send_message(email).body.
        encoded.should include(wr_log_url(action: "worth reading", 
                                          id: wr_log.id,
                                          host: "localhost:3000" ))
    end

    it "should have a web beacon" do
      UserMailer.send_message(email).body.encoded.
        should include("<img alt=\"Beacon\" src=\"/assets/http:localhost:3000/assets/beacon.gif\" />")
    end

    it "should deliver successfully" do
      lambda { UserMailer.send_message(email).deliver }.should_not raise_error
    end
  end

  describe "Alerting user of a change in the wr_log" do

    it "should render the alert of a change in the wr log email successfully" do
      lambda { UserMailer.alert_change_in_wr_log(wr_log) }.should_not raise_error
    end

    it "should idicate an email was worth reading" do
      UserMailer.alert_change_in_wr_log(wr_log).body.encoded.should match(/worth reading/m)
    end

    it "should deliver successfully" do
      lambda { UserMailer.alert_change_in_wr_log(wr_log).deliver }.should_not raise_error
    end
  end

  # Parsing implementation tests 
  #  describe "Parsed email" do 
  #    it "should render the first part of the message email successfully" do 
  #      lambda { UserMailer.first_pt_msg(email) }.should_not raise_error
  #    end
  #
  #    it "should deliver successfully" do
  #      lambda { UserMailer.first_pt_msg(email).deliver }.should_not raise_error
  #    end
  #
  #    context "rendered w/o error" do
  #      before { @mailer = UserMailer.first_pt_msg(email) }
  #        it "should parse the correct content" do
  #          @mailer.body.encoded.should match(/before/m)
  #        end
  #
  #        it "should not contain content after the more button" do
  #          @mailer.body.encoded.should_not match(/after/m)
  #        end
  #    end
  #  end

end
