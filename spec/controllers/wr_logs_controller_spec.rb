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
    {action: "email", sender_id: 1, receiver_id: 1, email_id: 1, email_part: 1, responded: false }
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

  describe "GET show" do
    it "assigns the requested wr_log as @wr_log" do
      wr_log = WrLog.create! valid_attributes
      get :show, {:id => wr_log.to_param}, valid_session
      assigns(:wr_log).should eq(wr_log)
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

  describe "PUT update" do
#      let (:sender) { User.create(name: "Sender", email: "sender@email.com", password: "foobar", password_confirmation: "foobar") }
#      let (:receiver) { User.create(name: "Receiver", email: "receiver@email.com", password: "foobar", password_confirmation: "foobar") }
      let (:email) { Email.create(to: "receiver@email.com", from: "sender@email.com", subject: "Subject",
                            body: "Blah, blah, blah. 
                                   <more>
                                   Bleh, bleh, bleh.
                                   <more>
                                   Blih.") }
      let (:sender) { User.find_by_email("sender@email.com")}
      let (:receiver) { User.find_by_email("receiver@email.com")}
      
    describe "with valid params" do
      it "updates the requested wr_log" do
        wr_log = WrLog.create!(action: "email", email_id: email.id, receiver_id: receiver.id, email_part: 0, responded: true )
        put :update, {:id => wr_log.id , :wr_log => { action: "more", email_part: 1}}
        # There should be a new WrLog entry like wr_log
        new_wr_log = WrLog.where("action = more AND email_id = #{email.id} AND receiver_id = #{receiver.id} AND
                                    email_part = 1 AND responded = true" ).first!
        # We render a page containing "Bleh, bleh, bleh. <href: ....>" where the button is another more put with the new
        #   entry's id and the command "more"
        subject { page }
        it {should have_link("more", href: "http://worth-reading.org/wr_log/#{new_wr_log.id}?request='more'") }
        
        
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

end
