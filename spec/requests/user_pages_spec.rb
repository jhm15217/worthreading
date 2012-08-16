require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "index" do

    let(:user) { FactoryGirl.create(:user) }

    before(:all) { 30.times { FactoryGirl.create(:user) } }
    after(:all)  { User.delete_all }

    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_selector('title', text: 'All users') }
    it { should have_selector('h1',    text: 'All users') }

    describe "pagination" do

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before do  
      sign_in user 
      visit user_path(user)
    end

    it { should have_selector('h3',    text: user.name) }
    it { should have_selector('title', text: user.name) }

    describe "adding a user as a subscriber button/subscribing to a user button" do
      let(:other_user) { FactoryGirl.create(:user) }

      context "when adding a user as a subscriber" do
        before { visit user_path(other_user) }

        it "should increment the user's subscribers count" do
          expect do 
            click_button "Add this person to my subscribers"
          end.to change(user.subscribers, :count).by(1)
        end

        it "should increment the other user's subscribed users count" do 
          expect do 
            click_button "Add this person to my subscribers"
          end.to change(other_user.subscribed_users, :count).by(1)
        end
      end

      context "when subscribing to a user" do
        before { visit user_path(other_user) }

        it "should increment the other user's subscribers count" do
          expect do
            click_button "Subscribe to this person"
          end.to change(other_user.subscribers, :count).by(1)
        end
      end

      context "when subscribing to a user" do
        it "should increment the user's subscribed_users count" do
          expect do
            click_button "Subscribe to this person"
          end.to change(user.subscribed_users, :count).by(1)
        end
      end
    end
  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Sign up') }
    it { should have_selector('title', text: full_title('Sign up')) }
  end

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }
        it { should have_selector('title', text: 'Sign up') }
        it { should have_content('error') }
      end    end

    describe "with valid information" do
      let(:name) { "Example User" }
      let(:email) { "user@example.com" }
      let(:password) { "foobar" }
      before do
        fill_in "Name",         with: name
        fill_in "Email",        with: email
        fill_in "Password",     with: password
        fill_in "Confirm Password", with: password
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "when a user is already registered through some previous registration" do
        before do 
          @user = User.create(name: "No one", 
                              email: "user@example.com", 
                              password: "123456",
                              password_confirmation: "123456")
        end

        context "when user isn't confirmed" do
          it "should update the user attributes" do 
            click_button submit
            @user.reload.name.should  == name 
            @user.reload.email.should == email 
            @user.reload.authenticate(password).should be_true
          end
        end

        context "when user is confirmed" do
          before do 
            @user.toggle!(:confirmed) 
            @user.reload
            click_button submit
          end
          it { should have_selector('title', text: 'Sign up') }
          it { should have_content('error') }
        end


      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_selector('title', text: "Email Confirmation Sent") }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end

    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_selector('h1',    text: "Update your profile") }
      it { should have_selector('title', text: "Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save the changes" }

      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save the changes"
      end

      it { should have_selector('title', text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should  == new_name }
      specify { user.reload.email.should == new_email }
    end
  end


  # TODO Change redirection later
  describe "user liking another user's message" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }

    it "should redirect to correct page" do
      sign_in user
      put likes_user_path(other_user.id) 
      response.should redirect_to(root_path)
    end

    it "should redirect if user not signed in" do
      put likes_user_path(other_user.id)
      response.should redirect_to(signin_path)
    end
  end

  describe "when confirming an email with confirmation link" do 
    let(:user) { FactoryGirl.create(:user) }
    let(:confirmation_token) { user.confirmation_token }

    before { user.toggle!(:confirmed) }

    it "should confirm user with correct confirmation token" do
      visit confirm_email_path(id: user.id, confirmation_token: confirmation_token)

      user.reload
      user.confirmed.should be_true
    end

    it "should redirect to user profile page if already confirmed" do
      user.toggle!(:confirmed)
      visit confirm_email_path(id: user.id, confirmation_token: confirmation_token)
    end

    it "shouldn't confirm user with incorrect confirmation token" do
      visit confirm_email_path(id: user.id, confirmation_token: "132afsdljksfd;kj")

      user.confirmed.should be_false
    end
  end
end
