class RelationshipsController < ApplicationController
  before_filter :signed_in_user

  def index
    @user = current_user
    @subscribers = @user.subscribers.paginate(page: params[:page])
    @subscriber_list = @subscribers.map do |subscriber|
      {name: subscriber.name,
        email: subscriber.email,
        id: subscriber.id,
        sent: WrLog.where("sender_id = #{@user.id} and receiver_id = #{subscriber.id}").count,
      opened: WrLog.where("sender_id = #{@user.id} and receiver_id = #{subscriber.id} and opened IS NOT NULL").count,
      liked: WrLog.where("sender_id = #{@user.id} and receiver_id = #{subscriber.id} and worth_reading IS NOT NULL").count } 
    end.sort_by {|h| -h[:liked] }
  end

  # Adds subscribers
  # Creates a user if user doesn't exist
  def create
    email_address_list(params[:email_addresses]).each do |user_parts|
      puts user_parts
      @user = find_or_register(user_parts[:email])
      if !@user
        puts "malformed"
        flash[:error] = "Malformed email address: #{user_parts[:email]}"
      else
        if current_user.subscribed_by?(@user)
          puts "already"
          flash[:error] = "#{user_parts[:email]} was already on your list."
        else
          puts "new"
          if @user.name = "Unknown" and user_parts[:name] != ""
            puts "new name"
            @user.name = user_parts[:name]
            @user.save
          end
          current_user.add_subscriber!(@user)
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to relationships_path }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).subscriber
    current_user.rem_subscriber!(@user)
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end
end
