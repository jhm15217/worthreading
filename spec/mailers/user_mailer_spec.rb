require "spec_helper"

describe UserMailer do
  let(:user) { FactoryGirl.create(:user) }
  let(:email) { FactoryGirl.create(:email) }
  let(:body)  { %Q{Hello world! Have to check the correct information is 
                   captured before.\n <more>\n This is more information after 
                   the more button. } }

  before do  
    email.from = user.email
    email.body = body
    email.save
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

    it "should deliver successfully" do
      lambda { UserMailer.send_message(email).deliver }.should_not raise_error
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
