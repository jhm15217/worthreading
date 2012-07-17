class RelationshipsController < ApplicationController
  before_filter :signed_in_user

  def create
    @user = User.find_by_email(params[:email])
    if current_user.subscribed_by?(@user) 
      redirect_to current_user, flash: { error: "You are already subscribed to him" }
    elsif 
      current_user.add_subscriber!(@user)
    else
      @user = User.create do |u|
      end
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
