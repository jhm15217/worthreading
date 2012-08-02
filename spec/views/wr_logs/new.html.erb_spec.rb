require 'spec_helper'

describe "wr_logs/new" do
  before(:each) do
    assign(:wr_log, stub_model(WrLog,
      :action => "MyString",
      :sender_id => 1,
      :receiver_id => 1,
      :email_id => 1,
      :email_part => 1
    ).as_new_record)
  end

  it "renders new wr_log form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => wr_logs_path, :method => "post" do
      assert_select "input#wr_log_action", :name => "wr_log[action]"
      assert_select "input#wr_log_sender_id", :name => "wr_log[sender_id]"
      assert_select "input#wr_log_receiver_id", :name => "wr_log[receiver_id]"
      assert_select "input#wr_log_email_id", :name => "wr_log[email_id]"
      assert_select "input#wr_log_email_part", :name => "wr_log[email_part]"
    end
  end
end
