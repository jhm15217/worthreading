class RelationshipsController < ApplicationController
  before_filter :signed_in_user

  def index
    @subscribers = current_user.subscribers
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
      format.html { redirect_to root_path }
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

  private

  def email_address_list(email_addresses)
    x = email_addresses.split(/,\s*/).map{|x| email_address_parts(x) }
  end

  # Captures formats i.e. 
  # "John Doe"<johndoe@example.com>, John Doe<johndoe@example.com>, johndoe@example.com
  def email_address_parts(email_address)
    if parts = (email_address.match('"([^"]*)"<(.*)>') or email_address.match('([a-zA-Z\s.]*)<(.*)>'))
      name = parts.captures[0]
      email_address = parts.captures[1]
    else
      name = ""
    end
    { name: name, email: email_address }
  end
end
