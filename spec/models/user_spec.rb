# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean         default(FALSE)
#  likes           :integer
#

require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", email: "user@example.com", 
                     password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:subscribers) }
  it { should respond_to(:subscribed_by?)}
  it { should respond_to(:add_subscriber!)}
  it { should respond_to(:rem_subscriber!)}
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:subscribed_users) }
  it { should respond_to(:likes) }
  it { should respond_to(:emails) }
  
  it { should be_valid }
  it { should_not be_admin }
  
  describe "with admin attribute set to 'true'" do
    before { @user.toggle!(:admin) }

    it { should be_admin }
  end

  describe "when name is not present" do
    before { @user.name = " "}
    it {should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end
  
  describe "after saving" do
    let(:default_likes) { 50 }
    before { @user.save }

    context "remember_token" do
      its(:remember_token) { should_not be_blank }
    end

    context "number_of likes" do
      its(:likes) { should == default_likes}
    end
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
                     addresses.each do |invalid_address|
                       @user.email = invalid_address
                       @user.should_not be_valid
                     end      
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end      
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  describe "likes incrementor/decrementor" do
    let(:other_user) { FactoryGirl.create(:user) }    
    let(:default_likes ) { 50 }
    let(:incr_by) { 5 }
    let(:decr_by) { 2 }
    before do
      @user.save
      @user.incr_decr_likes(other_user, incr_by, decr_by)
    end

    it "should increment the likes of one user and decrement the likes of the other" do
      @user.likes.should == default_likes + incr_by
      other_user.likes.should == default_likes - decr_by
    end
  end


  describe "email associations" do

    before { @user.save }
    let!(:older_email) do 
      FactoryGirl.create(:email, user: @user, created_at: 1.day.ago)
    end

    let!(:newer_email) do
      FactoryGirl.create(:email, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right emails in the right order" do
      @user.emails.should == [newer_email, older_email]
    end

    it "should destroy dependent emails" do
      emails = @user.emails
      @user.destroy
      emails.each do |email|
        Email.find_by_id(email.id).should be_nil
      end
    end
  end

  describe "Adding a subscriber" do
    let(:other_user) { FactoryGirl.create(:user)}
    before do
      @user.save
      @user.add_subscriber!(other_user)
    end

    it { should be_subscribed_by(other_user) }
    its(:subscribers) { should include(other_user) }

    describe "subscriber" do
      subject { other_user }
      its(:subscribed_users) { should include(@user) }
    end

    describe "and removing a subscriber" do
      before { @user.rem_subscriber!(other_user) }
      its(:subscribers) { should_not include(other_user) }
    end
  end

end



