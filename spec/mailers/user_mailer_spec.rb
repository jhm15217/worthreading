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
    email.to = other_user.email
    email.body = body
    email.save

    wr_log.sender_id = user.id
    wr_log.receiver_id = other_user.id
    wr_log.email_id = email.id
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
      lambda { UserMailer.send_message(email, wr_log, other_user) }.should_not raise_error
    end
    
    it "should have a Worth Reading link" do
      UserMailer.send_message(email, wr_log, other_user).body.encoded.should match(/Worth Reading/m)
    end

    it "should have the correct link for the Worth Reading link" do
      UserMailer.send_message(email, wr_log, other_user).body.
        encoded.should include(
          "http://localhost:3000/wr_logs/#{wr_log.id}?"\
          "token_identifier=#{wr_log.token_identifier}&amp;worth_reading=1")
    end

    it "should have a web beacon" do
      UserMailer.send_message(email, wr_log, other_user).body.encoded.
        should include("<img alt=\"\" src=\"http:\/\/localhost:3000/wr_logs/#{wr_log.id}/msg_opened/#{wr_log.token_identifier}\" />")
    end

    context "when there is a text email signature" do
      before { email.body = email.body + "----- Forwarded message ----\n-- \n John Doe" and email.save }
      it "should parse out a signature correctly and insert worth reading link in appropriate place" do
        UserMailer.send_message(email, wr_log, other_user).body.encoded.
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
        UserMailer.send_message(email, wr_log, other_user).body.encoded.
          should match(/Forwarded message.*<div class='signature'>/m)
      end
    end

    it "should deliver successfully" do
      lambda { UserMailer.send_message(email, wr_log, other_user).deliver }.should_not raise_error
    end
  end

  describe "Alerting user of a change in the wr_log" do
    context "when a User finds an email worth reading" do 
      before { wr_log.action = "worth reading" }
      it "should indicate an email was worth reading" do
        UserMailer.alert_change_in_wr_log(wr_log).body.encoded.should match(/worth reading/m)
      end

      it "should render the alert of a change in the wr log email successfully" do
        lambda { UserMailer.alert_change_in_wr_log(wr_log) }.should_not raise_error
      end

      it "should deliver successfully" do
        lambda { UserMailer.alert_change_in_wr_log(wr_log).deliver }.should_not raise_error
      end
    end

    context "when a User opens an email" do 
      before { wr_log.action = "opened" }
      it "should indicate an email was opened" do
        UserMailer.alert_change_in_wr_log(wr_log).body.encoded.should match(/opened/m)
      end

      it "should render the alert of a change in the wr log email successfully" do
        lambda { UserMailer.alert_change_in_wr_log(wr_log) }.should_not raise_error
      end

      it "should deliver successfully" do
        lambda { UserMailer.alert_change_in_wr_log(wr_log).deliver }.should_not raise_error
      end
    end
  end

  describe "when alerting a user of an error" do
    let(:error) { "There is an error" }
    it "should render the error email without erorr" do
      lambda { UserMailer.error_email(error, user, email) }.should_not raise_error
    end

    it "should deliver successfully" do
      lambda { UserMailer.error_email(error, user, email).deliver }.should_not raise_error
    end
  end


  describe "when sending a user a password reset email" do
    it "should render the error email without erorr" do
      lambda { UserMailer.password_reset(user) }.should_not raise_error
    end

    it "should deliver successfully" do
      lambda { UserMailer.password_reset(user).deliver }.should_not raise_error
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
