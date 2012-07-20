require "spec_helper"

describe UserMailer do
  let(:user) { FactoryGirl.create(:user) }

  describe "Welcome Email/Confirmation Email" do 
    it "should render the welcome email successfully" do 
      lambda { UserMailer.welcome_email(user) }.should_not raise_error
    end

    it "should deliver successfully" do
      lambda { UserMailer.welcome_email(user).deliver }.should_not raise_error
    end
  end

end
