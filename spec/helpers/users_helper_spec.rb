require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the EmailsHelper. For example:
#
describe UsersHelper do
  before do
    @user = User.create(name: "Example User", email: "user@example.com", 
                     password: "foobar", password_confirmation: "foobar")
   end
  describe "find_or_register" do
    it "finds registered user" do
      find_or_register("user@example.com") == @user
    end
    it "should increment the users count for unregistered person" do
      expect do
        find_or_register("newuser@example.com")
      end.to change(User, :count).by(1)
    end
    it "should return nil for a bad email address" do
      find_or_register("") == nil
    end
  end
end
