require 'spec_helper'

describe "wr_logs/show" do
  before(:each) do
    @wr_log = assign(:wr_log, stub_model(WrLog,
      :action => "Action",
      :sender_id => 1,
      :receiver_id => 2,
      :email_id => 3,
      :email_part => 4,
      :responded => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Action/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/false/)
  end
end
