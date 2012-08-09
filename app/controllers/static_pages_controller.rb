class StaticPagesController < ApplicationController
  def home
    if signed_in? 
      @user = current_user 
      @emails = @user.emails.paginate(page: params[:page])
      @users = User.all order: 'likes DESC'
    else
      @users = User.all
    end
  end

  def help
  end

  def about
  end

  def contact
  end

  def email_confirmation_sent
  end
end
