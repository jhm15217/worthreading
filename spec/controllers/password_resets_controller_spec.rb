require 'spec_helper'

describe PasswordResetsController do
  let(:user) { FactoryGirl.create(:user) }

  before { user.password_reset_sent_at = Time.now and user.save }

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    context "with correct confirmation token" do
      it "returns http success" do
        get 'edit', { id: user.id, confirmation_token: user.confirmation_token }
        response.should be_success
      end
    end

    context "with incorrect confirmation token" do
      it "returns a redirect" do
        get 'edit', { id: user.id, confirmation_token: "" }
        response.should be_redirect
      end
    end
  end

  describe "request for a password reset" do
    context "with a registered email" do
      it "should send a reset password email" do 
        expect { post :create, { email: user.email } }.
          to change(ActionMailer::Base.deliveries, :size).by(1)
      end
    end

    context "with an unregistered email" do
      before { user.confirmed = false and user.save(validate: false) }
      it "should not send an email" do
        expect { post :create, { email: "asdfas@afdkjasdlj.com" } }.
          to change(ActionMailer::Base.deliveries, :size).by(0)
      end
    end
  end

  describe "establishing a new password" do
    let(:new_pw) { "654321" }
    it "should change the password" do
      post :update, { id: user.id, 
        user: { password: new_pw, password_confirmation: new_pw } }
      user.reload
      user.authenticate(new_pw).should be_true
    end
  end
end
