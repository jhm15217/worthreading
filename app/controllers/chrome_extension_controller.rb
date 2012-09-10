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
    render inline: "<%= debug(params) %>" and return
    @user = current_user
    @user.emails.create!(
      from: @user.email,
      to: "subscribers@worth-reading.org",
      subject: params[:subject],
      body: params['body-html']
    )
    @user.subscribers.each do |subscriber|
      # Send message to each subscriber
    end
  end
end
