class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user =  User.find_by_email(params[:email])
    if user && user.confirmed
      user.send_password_reset 
      redirect_to signin_path, 
        flash: { notice: "Email sent with password reset instructions." }
    else
      flash.now { error: "Sorry, that email is not registered" }
      render new
    end
  end

  def edit
    confirm_user = User.find_by_id(params[:id]) == User.find_by_confirmation_token(params[:confirmation_token])
    @user = User.find(params[:id]) if confirm_user
    redirect_to root_path, flash: { error: "I can't let you do that" } unless @user
  end

  def update
    @user = User.find(params[:id])
    if @user.password_reset_sent < 1.hour.ago
      redirect_to signin_path, flash: { notice: "Your password reset has expired" }
    elsif @user.update_attributes(params[:user])
      redirect_to signin_path, flash: { success: "Your password has been reset" }
    else
      render :edit
    end
  end
end
