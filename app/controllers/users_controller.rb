class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :admin_user,     only: :destroy
    
  def show
    @user = User.find(params[:id])
  end

  def new
    if signed_in?
      redirect_to home
    else
      @user = User.new
    end
  end

  def create
    if signed_in?
      redirect_to home
    else
      @user = User.new(params[:user])

      respond_to do |format|
        if @user.save
          # Tell the UserMailer to send a welcome Email after save
          flash[:success] = "Welcome to Worth Reading!"
          sign_in @user
          UserMailer.welcome_email(@user).deliver

          format.html { redirect_to(@user) }
          format.json { render json: @user, status: :created, location: @user }
        else
          format.html { render action: "new" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
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

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
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

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
