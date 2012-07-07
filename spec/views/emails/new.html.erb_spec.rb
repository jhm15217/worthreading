require 'spec_helper'

describe "emails/new" do
  before(:each) do
    assign(:email, stub_model(Email,
      :from => "MyString",
      :to => "MyString",
      :subject => "MyString",
      :body => "MyText"
    ).as_new_record)
  end

  it "renders new email form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => emails_path, :method => "post" do
      assert_select "input#email_from", :name => "email[from]"
      assert_select "input#email_to", :name => "email[to]"
      assert_select "input#email_subject", :name => "email[subject]"
      assert_select "textarea#email_body", :name => "email[body]"
    end
  end
end
