class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_filter :correct_user,   only: [:edit, :update, :subscribed_to_list]
  before_filter :admin_user,     only: :destroy
    
  def show
    @user = User.find(params[:id])
    @emails = @user.emails
    @subscribers = @user.subscribers
    @email_count = @user.emails.count
  end

  def new
    if signed_in?
      redirect_to root_path
    else
      @user = User.new
    end
  end

  def create
    if signed_in?
      redirect_to home
    else

      # Checks if user already registered; i.e. User registered after sending an
      # email or User adds a subscriber who isn't a user thus creating a user for
      # that subscriber
      if @user = User.find_by_email(params[:user][:email]) and !@user.confirmed 
        @user.update_attributes(params[:user])
      else
        @user = User.new(params[:user])
        @user.save
      end

      respond_to do |format|
        if !@user.new_record?
          # Tell the UserMailer to send a welcome Email after save
          flash[:success] = "Welcome to Worth Reading!"
          UserMailer.welcome_email(@user).deliver

          # UserMailer.delay.welcome_email(@user)
          # User needs to confirm email first before being able to sign in
          format.html { redirect_to(email_confirmation_path(id: @user.id)) }
        else
          format.html { render action: "new" }
        end
      end
    end
  end

  def edit
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  # This will handle a like request; i.e. User hits like button and the user 
  # their likes decreased while the user whom they liked will have their likes increased
  # TODO Allow an ajax request to handle the like request to circumvent redirection
  def likes
    if signed_in? 
      liked_user = User.find_by_id!(params[:id])
      user_who_likes = current_user
      incr_likes = 6
      decr_likes = 5
      current_user.incr_decr_likes(liked_user, incr_likes, decr_likes) 
      sign_in user_who_likes
      redirect_to root_path 
    else
      redirect_to signin_path, flash: { notice: 'Hey, we need to know who you are first' }
    end
  end

  def resend_confirm_email
    @user = User.find(params[:id])
    UserMailer.welcome_email(@user).deliver
    redirect_to email_confirmation_path(id: @user.id)
  end

  # Confirms the email address of a user by matching confirmation token 
  def confirm_email
    confirmation_token = params[:confirmation_token]
    @user = User.find_by_id(params[:id])
    if @user.confirmation_token == confirmation_token && !@user.confirmed
      @user.confirmed = true 
      @user.save(validate: false)
    elsif @user.confirmed 
      redirect_to root_path, flash: { notice: "You already validated your email"}
    else
      flash[:error] = "Access denied"
    end
  end

  # GET
  def subscribed_to_list
    @user = User.find(params[:id])
    @subscribed_to = @user.subscribed_users.paginate(page: params[:page])
    @subscribed_list = @subscribed_to.map do |subscribed|
      {name: subscribed.name,
        email: subscribed.email,
        sent: WrLog.where("sender_id = #{subscribed.id} and receiver_id = #{@user.id}").count,
      opened: WrLog.where("sender_id = #{subscribed.id} and receiver_id = #{@user.id} and opened IS NOT NULL").count,
      liked: WrLog.where("sender_id = #{subscribed.id} and receiver_id = #{@user.id} and worth_reading IS NOT NULL").count } 
    end.sort_by {|h| -h[:liked] }
  end

  private

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
end
