# == Schema Information
#
# Table name: relationships
#
#  id            :integer         not null, primary key
#  follower_id   :integer
#  followed_id   :integer
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  subscriber_id :integer
#  subscribed_id :integer
#

require 'spec_helper'

describe Relationship do

  let(:subscriber) { FactoryGirl.create(:user)}
  let(:subscribed) { FactoryGirl.create(:user)}
  let(:relationship) { subscribed.relationships.build(subscriber_id: subscriber.id) }

  subject { relationship }

  it { should be_valid }

  describe "accessible attributes" do
    it "should not allow access to subscribed_id" do
      expect do
        Relationship.new(subscribed_id: subscribed.id)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end

  describe "subscription methods" do
    it { should respond_to(:subscriber) }
    it { should respond_to(:subscribed) }
    its(:subscriber) { should == subscriber }
    its(:subscribed) { should == subscribed }
  end

  describe "when subscribed id is not present" do
    before { relationship.subscribed_id = nil }
    it { should_not be_valid }
  end

  describe "when follower id is not present" do
    before { relationship.subscriber_id = nil }
    it { should_not be_valid }
  end
end

