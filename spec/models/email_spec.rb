# == Schema Information
#
# Table name: emails
#
#  id         :integer         not null, primary key
#  from       :string(255)
#  to         :string(255)
#  subject    :string(255)
#  body       :text
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe Email do
  let(:user) { FactoryGirl.create(:user) }
  before do
    @email = user.emails.build(to: "johndoe@worthreading.org",
                                    from: "janedoe@worthreading.org",
                                    subject: "Lorem Ipsum", 
                                    body: "Lorem Ipsum and other stuff")
  end

  subject { @email }
  it { should respond_to(:to) }
  it { should respond_to(:from) }
  it { should respond_to(:subject) }
  it { should respond_to(:body) }
  it { should respond_to(:user_id) }
  its(:user) { should == user } 
  it { should be_valid }

  describe "when a sender is not present" do 
    before { @email.to = " " }
    it { should_not be_valid }
  end

  describe "when a recipient is not present" do
    before { @email.from = " " }
    it { should_not be_valid }
  end

  describe "when a email body is not present" do
    before { @email.body = " "} 
    it { should_not be_valid }
  end

  describe "when an email is invalid" do
    let(:addresses) {%w[user@foo,com user_at_foo.org example.user@foo. 
      foo@bar_baz.com foo@bar+baz.com]}
    context "for the sender" do
      it "should not be valid" do
        addresses.each do |invalid_address|
          @email.to = invalid_address
          @email.should_not be_valid
        end
      end
    end

    context "for the recipient" do
      it "should not be valid" do
        addresses.each do |invalid_address|
          @email.to = invalid_address
          @email.should_not be_valid
        end
      end
    end
  end

  describe "accessible attributes" do
    it "should not allow access to user_id" do
      expect do
        Email.new(user_id: user.id)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end
end
