class RelationshipsController < ApplicationController
  before_filter :signed_in_user

  def index
    @subscribers = current_user.subscribers
  end

  # Adds subscribers
  # Creates a user if user doesn't exist
  def create
    @user = find_or_register(params[:email]) 

    # Checks if user saved and if it didn't, email was most likely invalid
    redirect_to(current_user, 
                flash: { error: "Invalid email address"}) and return if @user.new_record?

    if @user && current_user.subscribed_by?(@user) 
      flash[:error] = "That email address is already on your list"
    elsif !params[:email].blank?
      current_user.add_subscriber!(@user)
    end
    
    respond_to do |format|
      format.html { redirect_to current_user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).subscriber
    current_user.rem_subscriber!(@user)
    respond_to do |format|
      format.html { redirect_to current_user }
      format.js
    end
  end

end
