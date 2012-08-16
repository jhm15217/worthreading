class StaticPagesController < ApplicationController
  def home
    if signed_in? 
      @user = current_user 
      @emails = @user.emails.paginate(page: params[:page])
    else
      @users = User.all order: 'likes DESC'
    end
  end

  def help
  end

  def about
  end

  def contact
  end

  def email_confirmation_sent
    @user = User.find(params[:id])
  end
end
