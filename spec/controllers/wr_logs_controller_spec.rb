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

describe WrLogsController do

  # This should return the minimal set of attributes required to create a valid
  # WrLog. As you add validations to WrLog, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {action: "email", sender_id: 1, receiver_id: 1, email_id: 1, email_part: 1 }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # WrLogsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all wr_logs as @wr_logs" do
      wr_log = WrLog.create! valid_attributes
      get :index, {}, valid_session
      assigns(:wr_logs).should eq([wr_log])
    end
  end

  # get went to http://worth-reading/wr_log/id
  describe "GET show with :forward param" do
    let (:email) { FactoryGirl.create(:email) }
    let (:sender) { FactoryGirl.create(:user) }
    let (:receiver) { FactoryGirl.create(:user) }
    let(:wr_log) { FactoryGirl.create(:wr_log) }

    before do
      wr_log.email_id = email.id
      wr_log.receiver_id = receiver.id
      wr_log.sender_id = sender.id
      wr_log.save
      sender.add_subscriber!(receiver)
    end

    it "assigns the requested wr_log as @wr_log" do
      get :show, {:id => wr_log.id, forward: "1",
        token_identifier: wr_log.token_identifier }, valid_session
      assigns(:wr_log).should eq(wr_log)
    end


    describe "Receiver following Worth Reading link" do
      it "updates the requested wr_log" do
        get :show, {  id: wr_log.id, forward: "1",
                      token_identifier: wr_log.token_identifier }
        # responded is set to true
        wr_log.reload
        wr_log.action.should == "forward"
        wr_log.forwarded.should_not be_nil

      end

      context "and receiver is registered" do
        before { receiver.add_subscriber!(sender) }
        it "updates the requested wr_log" do
          get :show, {  id: wr_log.id, forward: "1",
                        token_identifier: wr_log.token_identifier }

          wr_log.reload
          wr_log.action.should == "forward"

          #  TODO Needs work
          # response.should have_selector("a", href: "http://worth-reading.org/registered") 
        end

        it "should forward email to subscribers" do
          if sender.email_notify?
            sender.toggle!(:email_notify)
          end
          get :show, {  id: wr_log.id, forward: "1",
                          token_identifier: wr_log.token_identifier }
          response.should have_selector("form",  action: "/forward",  method: "post")


        end

        it "should notify sender that the receiver forwarded their email" do
          expect { get :show, {  id: wr_log.id, forward: "1",
                          token_identifier: wr_log.token_identifier } }.
            to change(ActionMailer::Base.deliveries, :size).by(1)
            # to change(Delayed::Job, :count).by(1)
        end

        it "should not send any email if senders email_notify and receivers forward boxes are not checked" do
          sender.toggle!(:email_notify)
          expect { get :show, {  id: wr_log.id, forward: "1",
                          token_identifier: wr_log.token_identifier } }.
            to change(ActionMailer::Base.deliveries, :size).by(0)
            # to change(Delayed::Job, :count).by(0)
        end
      end
    end

  end

  # get went to http://worth-reading/wr_log/id
  describe "GET show with :more param" do
    let (:email) { FactoryGirl.create(:email) }
    let (:sender) { FactoryGirl.create(:user) }
    let (:receiver) { FactoryGirl.create(:user) }
    let(:wr_log) { FactoryGirl.create(:wr_log) }

    before do
      wr_log.email_id = email.id
      wr_log.receiver_id = receiver.id
      wr_log.sender_id = sender.id
      wr_log.email_part = 0
      wr_log.save
      sender.add_subscriber!(receiver)
      
      email.body = "Beginning of message\n<more>\nSecond Part of Message\n"
      email.parts = ["Beginning of message\n", "\nSecond Part of Message\n"]
      email.save
    end

    it "assigns the requested wr_log as @wr_log" do
      get :show, {:id => wr_log.id, more: "0",
        token_identifier: wr_log.token_identifier }, valid_session
      assigns(:wr_log).should eq(wr_log)
    end


    describe "Receiver following More link in email" do
      context "and receiver is unregistered" do
        it "updates the requested wr_log" do
          get :show, {  id: wr_log.id, more: "0",
                        token_identifier: wr_log.token_identifier }
          wr_log.reload
          wr_log.action.should == "more"
          wr_log.email_part.should == 1
        end
      end

      context "and receiver is registered" do
        before { receiver.add_subscriber!(sender) }
        it "updates the requested wr_log" do
          get :show, {  id: wr_log.id, more: "0",
                        token_identifier: wr_log.token_identifier }

          wr_log.reload
          wr_log.action.should == "more"
          wr_log.email_part.should == 1

          #  TODO Needs work
          # response.should have_selector("a", href: "http://worth-reading.org/show") 
        end

      end
    end
  end

  describe "GET msg_opened" do
    let (:email) { FactoryGirl.create(:email) }
    let (:sender) { FactoryGirl.create(:user) }
    let (:receiver) { FactoryGirl.create(:user) }
    let(:wr_log) { FactoryGirl.create(:wr_log) }

    before do
      wr_log.email_id = email.id
      wr_log.receiver_id = receiver.id
      wr_log.sender_id = sender.id
      wr_log.email_part = 0
      wr_log.save
    end

    context "when an wr_log token id is correct" do
      it "should update the wr_log indicating the user opened the email" do
        get :msg_opened, {:id => wr_log.id, token_identifier: wr_log.token_identifier}
        wr_log.reload
        wr_log.action.should == "opened"
        wr_log.opened.should_not be_nil
      end

      it "should send an email alerting Sender that the receiver opened their email" do
        wr_log.reload
        expect { get :msg_opened, { id: wr_log.id, token_identifier: wr_log.token_identifier } }.
          to change(ActionMailer::Base.deliveries, :size).by(1)
          # to change(Delayed::Job, :count).by(1)
      end
    end

    context "when an wr_log token id is incorrect" do
      it "shouldn't update the wr_log indicating the user opened the email" do
        get :msg_opened, {:id => wr_log.id, token_identifier: "1234lksad" }
        wr_log.reload
        wr_log.action.should_not == "opened"
      end
    end

    context "when a message is already opened" do
      before do 
        wr_log.action = "opened"
        wr_log.save
      end
      it "shouldn't send an email alert" do
        expect { get :msg_opened, { id: wr_log.id, token_identifier: wr_log.token_identifier } }.
          to change(Delayed::Job, :count).by(0)
      end
    end
  end

  describe "GET new" do
    it "assigns a new wr_log as @wr_log" do
      get :new, {}, valid_session
      assigns(:wr_log).should be_a_new(WrLog)
    end
  end

  describe "GET edit" do
    it "assigns the requested wr_log as @wr_log" do
      wr_log = WrLog.create! valid_attributes
      get :edit, {:id => wr_log.to_param}, valid_session
      assigns(:wr_log).should eq(wr_log)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new WrLog" do
        expect {
          post :create, {:wr_log => valid_attributes}, valid_session
        }.to change(WrLog, :count).by(1)
      end

      it "assigns a newly created wr_log as @wr_log" do
        post :create, {:wr_log => valid_attributes}, valid_session
        assigns(:wr_log).should be_a(WrLog)
        assigns(:wr_log).should be_persisted
      end

      it "redirects to the created wr_log" do
        post :create, {:wr_log => valid_attributes}, valid_session
        response.should redirect_to(WrLog.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved wr_log as @wr_log" do
        # Trigger the behavior that occurs when invalid params are submitted
        WrLog.any_instance.stub(:save).and_return(false)
        post :create, {:wr_log => {}}, valid_session
        assigns(:wr_log).should be_a_new(WrLog)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        WrLog.any_instance.stub(:save).and_return(false)
        post :create, {:wr_log => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "GET show" do
    let (:email) { FactoryGirl.create(:email) }
    let (:sender) { FactoryGirl.create(:user) }
    let (:receiver) { FactoryGirl.create(:user) }
    let(:wr_log) { FactoryGirl.create(:wr_log) }

    before do
      email[:body] = "First<more>Second<more>Third"
      email[:parts] = ["First", "Second", "Third"]
      email.save
      wr_log.action = "email"
      wr_log.email_id = email.id
      wr_log.receiver_id = receiver.id
      wr_log.sender_id = sender.id
      wr_log.email_part = 0
      wr_log.save
      sender.add_subscriber(receiver)
    end

    describe "with valid params, more=0" do
      render_views
      it "updates the requested wr_log" do
        put :show, { id: wr_log.id, more: "0", token_identifier: wr_log.token_identifier   }
        # There should be a new WrLog entry like wr_log
        WrLog.where("action = 'more' AND email_id = #{email.id} AND receiver_id = #{receiver.id} AND email_part = '1'").
            first!.id.should == wr_log.id
        # We render a page containing "Bleh bleh bleh". <href: ....> where the button is another more put with value
        # of 1 and the command "more"

        response.body.should match("wr_logs/#{wr_log.id}.*more=1")
      end

        it "assigns the requested wr_log as @wr_log" do
        wr_log = WrLog.create! valid_attributes
        put :update, {:id => wr_log.to_param, :wr_log => valid_attributes}, valid_session
        assigns(:wr_log).should eq(wr_log)
      end

      it "redirects to the wr_log" do
        wr_log = WrLog.create! valid_attributes
        put :update, {:id => wr_log.to_param, :wr_log => valid_attributes}, valid_session
        response.should redirect_to(wr_log)
      end
    end

    describe "with valid params, more=1" do
      render_views
      it "updates the requested wr_log" do
        put :show, { id: wr_log.id, more: "1", token_identifier: wr_log.token_identifier   }
        # There should be a new WrLog entry like wr_log
        WrLog.where("action = 'more' AND email_id = #{email.id} AND receiver_id = #{receiver.id} AND email_part = '2'").
            first!.id.should == wr_log.id
        # We render a page containing "Bleh bleh bleh". <href: ....> where the button is another more put with value
        # of 1 and the command "more"

        response.body.should match("wr_logs/#{wr_log.id}.*forward")
      end
    end


      describe "with invalid params" do
      it "assigns the wr_log as @wr_log" do
        wr_log = WrLog.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        WrLog.any_instance.stub(:save).and_return(false)
        put :update, {:id => wr_log.to_param, :wr_log => {}}, valid_session
        assigns(:wr_log).should eq(wr_log)
      end

      it "re-renders the 'edit' template" do
        wr_log = WrLog.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        WrLog.any_instance.stub(:save).and_return(false)
        put :update, {:id => wr_log.to_param, :wr_log => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested wr_log" do
      wr_log = WrLog.create! valid_attributes
      expect {
        delete :destroy, {:id => wr_log.to_param}, valid_session
      }.to change(WrLog, :count).by(-1)
    end

    it "redirects to the wr_logs list" do
      wr_log = WrLog.create! valid_attributes
      delete :destroy, {:id => wr_log.to_param}, valid_session
      response.should redirect_to(wr_logs_url)
    end
  end

  describe "GET/wr_logs/1/follow/token_identifier" do
    let (:email) { FactoryGirl.create(:email) }
    let (:sender) { FactoryGirl.create(:user) }
    let (:receiver) { FactoryGirl.create(:user) }
    it "redirects to original url" do
      wr_log = WrLog.create!(sender_id: sender.id, receiver_id: receiver.id, email_id: email.id, url: "xxx")
      get :follow, {id: wr_log.id, token_identifier: wr_log.token_identifier}
      response.should redirect_to("xxx")
    end

  end

end
