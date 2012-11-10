require 'spec_helper'

describe ChromeExtensionController do
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:user3) { FactoryGirl.create(:user) }

  before do
    sign_in user
    User.all.each { |u| user.add_subscriber!(u) unless u == user }
  end



  describe "Sending email with link" do
    it "should not raise an error" do
      expect { post :create, { :to => "subscribers@worth-reading.org", :subject => "A subject",
                               :body => "Hey check out \n www.google.com" } }.
          should_not raise_error
    end
  end




  # TODO Rework test
  # it "should send an email to all users" do
  #   expect { post :create, { :subject => "A subject",
  #     :body => "Hey check out \n www.google.com" } }.
  #     to change(ActionMailer::Base.deliveries, :size).by(user.subscribers.count)
  # end
end


