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
    failed_addresses = ""
    email_address_list(params[:email_addresses]).each do |user_parts|
      @user = find_or_register(user_parts[:email])
      if !@user
        failed_addresses = failed_addresses + '"' + user_parts[:name] + '"<' + user_parts[:email] + '>, '
      else
        if current_user.subscribed_by?(@user)
          flash[:error] = "#{user_parts[:email]} was already on your list."
        else
          if @user.name == "Unknown" and user_parts[:name] != ""
            @user.name = user_parts[:name]
            @user.password = @user.password_confirmation = "Unknown"
            @user.save!
          end
          current_user.add_subscriber!(@user)
        end
      end
      if !failed_addresses.blank?
        flash.now[:error] = "Malformed email address(es)"
        params[:email_addresses] = failed_addresses
        render
      end
    end

    respond_to do |format|
      format.html { redirect_to relationships_path }
      format.js
    end
  end

  def destroy
    if params[:subscribed]
      @user =  Relationship.find(params[:id]).subscribed
      current_user.rem_subscribed!(@user)
      respond_to do |format|
        format.html { redirect_to subscribed_to_list_user_path current_user }
        format.js
      end
    else
      @user = Relationship.find(params[:id]).subscriber
      current_user.rem_subscriber!(@user)
      respond_to do |format|
        format.html { redirect_to relationships_path }
        format.js
      end
    end
  end
end
