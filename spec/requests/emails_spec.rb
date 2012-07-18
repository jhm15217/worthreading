require 'spec_helper'

describe "Emails" do
  describe "GET /emails" do
    context "when not signed in"  do
      it "should redirect" do
        # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
        get emails_path
        response.should redirect_to(signin_path) 
      end
    end
  end
end
