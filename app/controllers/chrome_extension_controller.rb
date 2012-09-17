class ChromeExtensionController < ApplicationController
  before_filter :signed_in_user
  protect_from_forgery :except => :new

  # GET chrome_extension/new
  # Page where users can choose to send a link after clicking 
  # the chrome-extension button
  def new
    require 'uri'
    @user = current_user
    @text = URI.unescape(params[:text]) unless URI.unescape(params[:text]).blank?
    @link = params[:link]
    @subject = URI.unescape(params[:text]).match(/^.{120,}?[.?!]+(?=\s|$)/) unless URI.unescape(params[:text]).blank?
  end

  # POST 
  # Creates the email that will include the link that will be 
  # sent to a user's subscribers
  def create
    @user = current_user
    @email = @user.emails.create!(
      from: @user.email,
      to: params[:to],
      subject: params[:subject],
      body: params['body'].gsub("\n", "\n<br />"),
      parts: params['body'].gsub("\n", "\n<br />").split(/&lt;more&gt;|<more>/)
    )

    @email.deliver_all(@email.process(@user))
    redirect_to root_path, flash: { success: "Email successfully sent" }
  end
end
