require 'spec_helper'

describe RelationshipsController do

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before { sign_in user }

  describe "creating a subscriber" do
    context "with a valid email" do
      it "should increase subscribers by 1" do
        expect do
          post :create, { email_addresses: other_user.email }
        end.should change(Relationship, :count).by(1)
      end

      it "should respond with a redirect" do
        post :create, { email_addresses: other_user.email }
        response.should be_redirect
      end
    end

    context "when already subscribed to user" do
      before { user.add_subscriber!(other_user) }
      it "should redirect with a flash msg 'the email is already on the list'" do
        post :create, { email_addresses: other_user.email }
        response.should be_redirect
        flash[:error].should =~ /^#{other_user.email} .* list./i
      end
    end

    context "with an invalid email" do
      before { other_user.email = " " }
      it "should redirect with a flash message 'Malformed email address'" do
        post :create, { email_addresses: other_user.email }
        response.should be_redirect
        # flash.now[:error].should =~ /Malformed email address/i
      end
    end
  end

  describe "removing a subscriber" do 
    before { user.add_subscriber!(other_user) }
    let(:relationship) { user.relationships.find_by_subscriber_id(other_user) }
    it "should decrease subscriber count by 1" do
      expect do
        delete :destroy, { id: relationship.id }
      end.should change(Relationship, :count).by(-1)
    end

    it "should respond with a redirect" do
      delete :destroy, { id: relationship.id }
      response.should be_redirect
    end
  end

  # TODO Rewrite tests
  #  describe "creating a relationship with Ajax" do
  #
  #    it "should increment the Relationship count" do
  #      expect do
  #        xhr :post, :create, relationship: { followed_id: other_user.id }
  #      end.should change(Relationship, :count).by(1)
  #    end
  #
  #    it "should respond with success" do
  #      xhr :post, :create, relationship: { followed_id: other_user.id }
  #      response.should be_success
  #    end
  #  end
  #
  #  describe "destroying a relationship with Ajax" do
  #
  #    before { user.follow!(other_user) }
  #    let(:relationship) { user.relationships.find_by_followed_id(other_user) }
  #
  #    it "should decrement the Relationship count" do
  #      expect do
  #        xhr :delete, :destroy, id: relationship.id
  #      end.should change(Relationship, :count).by(-1)
  #    end
  #
  #    it "should respond with success" do
  #      xhr :delete, :destroy, id: relationship.id
  #      response.should be_success
  #    end
  #  end
end
