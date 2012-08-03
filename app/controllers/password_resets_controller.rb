class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user =  User.find_by_email(params[:email])
    user.send_password_reset if user

    redirect_to signin_path, 
      flash: { notice: "Email sent with password reset instructions." }
  end

  def edit
    confirm_user = User.find_by_id(params[:id]) == User.find_by_confirmation_token(params[:confirmation_token])
    @user = User.find(params[:id]) if confirm_user
    redirect_to root_path, flash: { error: "I can't let you do that" } unless @user
  end

  def update
    @user = User.find(params[:id])
    if @user
  end
end
