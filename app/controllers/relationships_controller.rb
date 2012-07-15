class RelationshipsController < ApplicationController
  before_filter :signed_in_user

  def create
    @user = User.find_by_email(params[:email])
    current_user.add_subscriber!(@user)
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
