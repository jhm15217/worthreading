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
    redirect_to root_path and return unless params[:id]
    @user = User.find(params[:id])
  end

  def whats_this
    # @log = WrLog.find(params[:id])
  end
end
