require 'spec_helper'

describe "Static pages" do

  subject { page }

  shared_examples_for "all static pages" do
     it { should have_selector('h2',    text: heading) }
     it { should have_selector('title', text: full_title(page_title)) }
   end

   describe "Home page" do
     before { visit root_path }
     let(:heading)    { 'Worth Reading' }
     let(:page_title) { '' }

     it_should_behave_like "all static pages"
     it { should_not have_selector 'title', text: '| Home' }

     describe "for signed-in users" do
       let(:user) { FactoryGirl.create(:user) }
       before do
         sign_in user
         visit root_path
       end
     end
  end

  describe "Help page" do
    before { visit help_path }

    it { should have_selector('title', text: full_title('Help')) }
  end

  describe "About page" do
    before { visit about_path }
    it { should have_selector('title', text: full_title('About Us')) }
  end

  describe "Contact page" do
    before { visit contact_path }

    it { should have_selector('h1',    text: 'Contact') }
    it { should have_selector('title', text: full_title('Contact')) }
  end

  describe "Email Confirmation Sent Page" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      user.toggle! :confirmed
      visit { email_confirmation_path(id: user.id)}
      it { should have_selector('input.btn'), 
                                  value: 'Resend Email Confirmation'}
    end
  end

  describe "What's this page" do
    let(:sender) { FactoryGirl.create(:user) }
    let(:email) { FactoryGirl.create(:email) }
    let(:log) { FactoryGirl.create(:wr_log) }

    before do
      log.email_id = email.id
      log.sender_id = sender.id
      log.save
    end

    describe "when visiting with incorrect parameters" do
      it "should redirect to homepage" do
        get whats_this_path 
        response.should redirect_to root_path
      end
    end

    describe "when visiting with correct parameters" do
      before { visit whats_this_path(id: log.id, token_identifier: log.token_identifier ) }
      it "should not redirect to homepage" do
        get whats_this_path(id: log.id, token_identifier: log.token_identifier) 
        response.should_not redirect_to root_path
      end

      it { should have_selector('a', text: "Join Worth Reading") } 
    end
  end
end
