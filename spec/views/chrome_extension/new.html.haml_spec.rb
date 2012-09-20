require "spec_helper"

describe "chrome_extension/new" do

  before(:each) do
    @user = User.create(name: "AAAA", email: "EmailA@email.com", password: "password", password_confirmation: "password")
    user2 = User.create!(name: "BBBB", email: "EmailB@email.com", password: "password", password_confirmation: "password")
    user3 = User.create!(name: "CCCC", email: "EmailC@email.com", password: "password", password_confirmation: "password")
    @user.add_subscriber(user2)
    @user.add_subscriber(user3)
    @subject = ""
    @text = ""
  end


  it "renders to field with subscribers" do
    render
    assert_select "form>input", :to => '"BBBB"<emailB@email.com>'
    assert_select "form>input", :to => '"CCCC"<emailC@email.com>'
  end
end