class StaticPagesController < ApplicationController
  def home
    if signed_in? 
      @user = current_user 
      two_weeks_ago = Time.now.weeks_ago(2)
      @emails = current_user.emails.where("created_at >= ?", two_weeks_ago )
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
