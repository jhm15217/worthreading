class RelationshipsController < ApplicationController
  before_filter :signed_in_user

  # Adds subscribers
  # Creates a user if user doesn't exist
  def create
    @user = find_or_register(params[:email]) 
    if current_user.subscribed_by?(@user) 
      flash[:error] = "That email address is already on your list"
    else
      current_user.add_subscriber!(@user)
    end
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    # TODO Recreate after revamping the view
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
