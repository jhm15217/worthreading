class RelationshipsController < ApplicationController
  before_filter :signed_in_user, except: [:email_unsubscribe, :unsubscribe_from_mailing_list]

  def index
    @user = current_user
    @subscribers = @user.subscribers
    @subscriber_list = @subscribers.map do |subscriber|
      {subscriber: subscriber,
        email: subscriber.email,
        id: subscriber.id,
        sent: WrLog.where("sender_id = #{@user.id} and receiver_id = #{subscriber.id}").count,
        opened: WrLog.where("sender_id = #{@user.id} and receiver_id = #{subscriber.id} and opened IS NOT NULL").count,
        followed_url: WrLog.where("sender_id = #{@user.id} and receiver_id = #{subscriber.id} and followed_url IS NOT NULL").count,
        forwarded: WrLog.where("sender_id = #{@user.id} and receiver_id = #{subscriber.id} and forwarded IS NOT NULL").count }
    end.sort {|a,b| 4 * (b[:forwarded]<=>a[:forwarded]) + 2 * (b[:followed_url]<=>a[:followed_url]) + b[:opened]<=>a[:opened]  }
       .paginate(page: params[:page], per_page:30)
  end

  # Adds subscribers
  # Creates a user if user doesn't exist
  def create
    failed_addresses = ""
    email_address_list(params[:email_addresses]).each do |user_parts|
      @user = Email.find_or_register(user_parts[:email])
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
    end
    if !failed_addresses.blank?
      # I want to put the bad addresses back into the form so the user can correct them. How?
      flash.now[:error] = "Malformed email address(es)"
      params[:email_addresses] = failed_addresses
      render
    end

    respond_to do |format|
      format.html { redirect_to relationships_path }
      format.js
    end
  end

  # Adds subscribers
  # Creates a user if user doesn't exist
  def add_sources
    failed_addresses = ""
    email_address_list(params[:email_addresses]).each do |user_parts|
      @user = Email.find_or_register(user_parts[:email])
      if !@user
        failed_addresses = failed_addresses + '"' + user_parts[:name] + '"<' + user_parts[:email] + '>, '
      else
        if @user.subscribed_by?(current_user)
          flash[:error] = "#{user_parts[:email]} was already on your list."
        else
          if @user.name == "Unknown" and user_parts[:name] != ""
            @user.name = user_parts[:name]
            @user.password = @user.password_confirmation = "Unknown"
            @user.save!
          end
          @user.add_subscriber!(current_user)
        end
      end
    end
    if !failed_addresses.blank?
      # I want to put the bad addresses back into the form so the user can correct them. How?
      flash.now[:error] = "Malformed email address(es)"
      params[:email_addresses] = failed_addresses
      render
    end

    respond_to do |format|
      format.html { redirect_to subscribed_to_list_user_path current_user }
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

  # Methods for unsubscribing from a user from an email message sent 
  # GET
  def email_unsubscribe
    
    if @relationship = Relationship.find_by_id(params[:id]) and 
      @relationship.token_identifier == params[:token_identifier]

      @subscribed = @relationship.subscribed
      @subscriber = @relationship.subscriber
    else
      redirect_to root_path, flash: { error: "Invalid access" }
    end
  end

  # DELETE
  def unsubscribe_from_mailing_list 
    @relationship = Relationship.find(params[:id])
    if @relationship.token_identifier == params[:token_identifier]
      @relationship.destroy
      redirect_to root_path, flash: { success: "Unsubscribed from the mailing list"}
    else
      redirect_to root_path, flash: { error: "Invalid access" }
    end
  end
end
