class ChromeExtensionController < ApplicationController
  before_filter :signed_in_user

  # GET chrome_extension/new
  # Page where users can choose to send a link after clicking 
  # the chrome-extension button
  def new
    @link = params[:link]
  end

  # POST 
  # Creates the email that will include the link that will be 
  # sent to a user's subscribers
  def create
    @user = current_user
    
    @email = @user.emails.create!(
      from: @user.email,
      to: "subscribers@worth-reading.org",
      subject: params[:subject],
      body: params['body'].gsub("\n", "\n<br />")
    )
    @email.deliver_all(@email.process(@user))
    redirect_to root_path, flash: { success: "Email successfully sent" }
  end
end