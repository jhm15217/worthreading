require 'spec_helper'

describe "wr_logs/index" do
  before(:each) do
    user1 = User.create!(name: "AAAA", email: "EmailA@email.com", password: "password", password_confirmation: "password")
    user2 = User.create!(name: "BBBB", email: "EmailB@email.com", password: "password", password_confirmation: "password")
    email = Email.create!(to: "EmailB@email.com", from: "EmailA@email.com", subject:"Subject", body: "Body")
    assign(:wr_logs, [
      stub_model(WrLog,
        :action => "email",
        :sender_id => user1.id,
        :receiver_id => user2.id,
        :email_id => email.id,
        :email_part => 1
      ),
      stub_model(WrLog,
        :action => "email",
        :sender_id => user1.id,
        :receiver_id => user2.id,
        :email_id => email.id,
        :email_part => 1
      )
    ])
  end


  it "renders a list of wr_logs" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "AAAA".to_s, :count => 2
    assert_select "tr>td", :text => "BBBB".to_s, :count => 2
    assert_select "tr>td", :text => "Subject".to_s, :count => 2
  end
end
