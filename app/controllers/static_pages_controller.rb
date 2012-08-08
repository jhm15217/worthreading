class StaticPagesController < ApplicationController
  def home
    if signed_in? 
      @user = current_user 
      @emails = @user.emails
      @email_count = @user.emails.count
      @subscribers = @user.subscribers
      if Rails.env.production?
        @subscriber_list = @subscribers.map do |subscriber|
          {name: subscriber.name,
            email: subscriber.email,
            id: subscriber.id,
            sent: WrLog.where("sender_id = #{@user.id} and receiver_id = #{subscriber.id}").count,
          opened: WrLog.where("sender_id = #{@user.id} and receiver_id = #{subscriber.id} and opened IS NOT NULL").count,
          liked: WrLog.where("sender_id = #{@user.id} and receiver_id = #{subscriber.id} and worth_reading IS NOT NULL").count } 
        end.sort_by {|h| -h[:liked] }
      else
        @subscriber_list = @subscribers.map do |subscriber|
          {name: subscriber.name,
            email: subscriber.email,
            id: subscriber.id,
            sent: WrLog.where("sender_id = #{@user.id} and receiver_id = #{subscriber.id}").count,
          opened: WrLog.where("sender_id = #{@user.id} and receiver_id = #{subscriber.id} and opened").count,
          liked: WrLog.where("sender_id = #{@user.id} and receiver_id = #{subscriber.id} and worth_reading").count } 
        end.sort_by {|h| -h[:liked] }
      end
    end
    @users = User.all order: 'likes DESC'
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
