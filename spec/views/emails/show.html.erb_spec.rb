require 'spec_helper'

describe "emails/show" do
  before(:each) do
    @email = assign(:email, stub_model(Email,
      :from => "From",
      :to => "To",
      :subject => "Subject",
      :body => "MyText"
    ))
  end

    # it "renders attributes in <p>" do
    #   render
    #   # Run the generator again with the --webrat flag if you want to use webrat matchers
    #   rendered.should match(/From/)
    #   rendered.should match(/To/)
    #   rendered.should match(/Subject/)
    # end
  end
end
