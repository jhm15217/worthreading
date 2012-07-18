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

    it { should have_selector('h1',    text: 'Help') }
    it { should have_selector('title', text: full_title('Help')) }
  end

  describe "About page" do
    before { visit about_path }

    it { should have_selector('h1',    text: 'About') }
    it { should have_selector('title', text: full_title('About Us')) }
  end

  describe "Contact page" do
    before { visit contact_path }

    it { should have_selector('h1',    text: 'Contact') }
    it { should have_selector('title', text: full_title('Contact')) }
  end
end
