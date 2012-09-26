require 'spec_helper'

describe "emails/new" do
  before(:each) do
    assign(:email, stub_model(Email,
      :from => "From",
      :to => "To",
      :subject => "Subject",
      :body => "Body"
    ).as_new_record)
  end

  it "renders new email form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => emails_path, :method => "post" do
      assert_select "input#email_from", :name => "From"
      assert_select "input#email_to", :name => "To"
      assert_select "input#email_subject", :name => "Subject"
      assert_select "textarea#email_body", :name => "Body"
    end
  end
end
