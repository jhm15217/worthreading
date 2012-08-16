require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe EmailsController do
  before(:all) { 5.times { FactoryGirl.create(:user)} }
  after(:all)  { User.delete_all }

  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user)}
  let(:user3) { FactoryGirl.create(:user)}

  describe "receiving an email to individual via a POST request from Mailgun" do
    it "should render a text 'Email Received' after a successful save" do
      post :create, {'from' => user.email,
        'Delivered-To' => "joe+email.com@worth-reading.org", 
        'subject' => "Nothing", 
        'body-plain' => "Lorem Ipsum" }
      response.should be_successful 
    end

#    it "should add an entry to WrLog" do
#      expect do
#        post :create, {'from' => user.email, 
#          'Delivered-To' => "subscribers@worth-reading.org.mailgun.ort", 
#          'subject' => "Nothing", 
#          'body-plain' => "Lorem Ipsum" }
#      end.to change(WrLog, :count).by(1)
#    end

      it "should create the individual" do
        post :create, {'from' => user.email, 
          'Delivered-To' => "joe+email.com@worth-reading.org", 
          'subject' => "Nothing", 
          'body-plain' => "Lorem Ipsum" }
        User.find_by_email("joe@email.com").should_not be nil
      end

      it "should send an email to the individual" do
        expect { post :create, {'from' => user.email, 
          'Delivered-To' => "joe+email.com@worth-reading.org", 
          'subject' => "Nothing", 
          'body-plain' => "Lorem Ipsum" } }.
          to change(ActionMailer::Base.deliveries, :size).by(1)
          # to change(Delayed::Job, :count).by(1)
      end

      it "should make an individual a suscriber" do
        post :create, {'from' => user.email, 
          'Delivered-To' => "joe+email.com@worth-reading.org", 
          'subject' => "Nothing", 
          'body-plain' => "Lorem Ipsum" }
        user.subscribed_by?(User.find_by_email("joe@email.com")).should_not be nil
      end
    end

  describe "receiving an email from via a POST request from Mailgun" do
    it "should render a text 'Email Received' after a successful save" do
      post :create, {'from' => user.email,
        'Delivered-To' => "subscribers@worth-reading.org", 
        'subject' => "Nothing", 
        'body-plain' => "Lorem Ipsum" }
      response.should be_successful 
    end

#    it "should add an entry to WrLog" do
#      expect do
#        post :create, {'from' => user.email, 
#          'Delivered-To' => "subscribers@worth-reading.org.mailgun.ort", 
#          'subject' => "Nothing", 
#          'body-plain' => "Lorem Ipsum" }
#      end.to change(WrLog, :count).by(1)
#    end

    it "should redirect if Email could has bad sender" do
      post :create, {'from' => " ", 
        'Delivered-To' => "jan@mail.com", 
        'subject' => "Nothing"}
      response.should be_redirect
    end

#    it "should report error if Email could has bad receiver" do
#      post :create, {'from' => user.email, 
#        'Delivered-To' => "jan+mail@worth-reading.org", 
#        'subject' => "Nothing"}
#      response.should be_error
#    end

    context "with subscribers on his/her list" do
      before do
        user.add_subscriber!(user2)
        user.add_subscriber!(user3)
      end

      it "should send out email to all subscribers" do
        expect { post :create, {'from' => user.email, 
          'Delivered-To' => "subscribers@worth-reading.org", 
          'subject' => "Nothing", 
          'body-plain' => "Lorem Ipsum" } }.
          to change(ActionMailer::Base.deliveries, :size).by(user.subscribers.count)
          # to change(Delayed::Job, :count).by(1)
      end
    end

    context "without any subscribers on the list" do
      let(:user4) { FactoryGirl.create(:user) }
      let(:error) { "Error occured" }

      it "should send out an error" do 
        expect { post :create, {'from' => user4.email, 
          'Delivered-To' => "subscribers@worth-reading.org", 
          'subject' => "Nothing", 
          'body-plain' => "Lorem Ipsum" } }.
          to change(ActionMailer::Base.deliveries, :size).by(1)
          # to change(Delayed::Job, :count).by(1)
      end
    end
  end
  # 
  #   # This should return the minimal set of attributes required to create a valid
  #   # Email. As you add validations to Email, be sure to
  #   # update the return value of this method accordingly.
  #   def valid_attributes
  #     {}
  #   end
  #   
  #   # This should return the minimal set of values that should be in the session
  #   # in order to pass any filters (e.g. authentication) defined in
  #   # EmailsController. Be sure to keep this updated too.
  #   def valid_session
  #     {}
  #   end
  # 
  #   describe "GET index" do
  #     it "assigns all emails as @emails" do
  #       email = Email.create! valid_attributes
  #       get :index, {}, valid_session
  #       assigns(:emails).should eq([email])
  #     end
  #   end
  # 
  #   describe "GET show" do
  #     it "assigns the requested email as @email" do
  #       email = Email.create! valid_attributes
  #       get :show, {id: email.to_param}, valid_session
  #       assigns(:email).should eq(email)
  #     end
  #   end
  # 
  #   describe "POST create" do
  #     describe "with valid params" do
  #       it "assigns a newly created email as @email" do
  #         post :create, {:email => valid_attributes}, valid_session
  #         assigns(:email).should be_a(Email)
  #         assigns(:email).should be_persisted
  #       end
  # 
  #       it "creates a new Email" do
  #         expect {
  #           post :create, {:email => valid_attributes}, valid_session
  #         }.to change(Email, :count).by(1)
  #       end
  #     end
  # 
  #     describe "with invalid params" do
  #       it "assigns a newly created but unsaved email as @email" do
  #         # Trigger the behavior that occurs when invalid params are submitted
  #         Email.any_instance.stub(:save).and_return(false)
  #         post :create, {:email => {}}, valid_session
  #         assigns(:email).should be_a_new(Email)
  #       end
  #     end
  #   end
  # 
  #   describe "DELETE destroy" do
  #     it "destroys the requested email" do
  #       email = Email.create! valid_attributes
  #       expect {
  #         delete :destroy, {:id => email.to_param}, valid_session
  #       }.to change(Email, :count).by(-1)
  #     end
  # 
  #     it "redirects to the emails list" do
  #       email = Email.create! valid_attributes
  #       delete :destroy, {:id => email.to_param}, valid_session
  #       response.should redirect_to(emails_url)
  #     end
  #   end
  # 
end
