require 'spec_helper'

describe "wr_logs/index" do
  before(:each) do
    assign(:wr_logs, [
      stub_model(WrLog,
        :action => "Action",
        :sender_id => 1,
        :receiver_id => 2,
        :email_id => 3,
        :email_part => 4,
        :responded => false
      ),
      stub_model(WrLog,
        :action => "Action",
        :sender_id => 1,
        :receiver_id => 2,
        :email_id => 3,
        :email_part => 4,
        :responded => false
      )
    ])
  end

  it "renders a list of wr_logs" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Action".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
