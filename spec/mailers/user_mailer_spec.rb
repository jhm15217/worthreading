require "spec_helper"
describe UserMailer do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:email) { FactoryGirl.create(:email) }
  let(:wr_log) { FactoryGirl.create(:wr_log) }

  before do  
    user.add_subscriber!(other_user)
  end

  describe "Welcome Email/Confirmation Email" do 
    it "should render the welcome email successfully" do 
      lambda { UserMailer.welcome_email(user) }.should_not raise_error
    end

    it "should deliver successfully" do
      lambda { UserMailer.welcome_email(user).deliver }.should_not raise_error
    end
  end

  describe "Alerting user of a change in the wr_log" do
    let(:body)  { %Q{Hello world! Have to check the correct information is 
                     captured before.} }

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

    context "when a User finds an email worth reading" do 
      before { wr_log.action = "forward" }
      it "should indicate an email was forwarded" do
        UserMailer.alert_change_in_wr_log(wr_log).body.encoded.should match(/forwarded/m)
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
      expect { UserMailer.password_reset(user) }.should_not raise_error
    end

    it "should deliver successfully" do
      expect { UserMailer.password_reset(user).deliver }.should_not raise_error
    end
  end

end
