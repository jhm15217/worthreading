class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email])
     if user && user.authenticate(params[:session][:password]) && user.confirmed
       sign_in user
       redirect_back_or root_path 
     elsif user && !user.confirmed
       flash.now[:error] = "You haven't confirmed your email yet." 
       render 'new'
     else
       flash.now[:error] = 'Invalid email/password combination' # Not quite right!
       render 'new'
     end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
