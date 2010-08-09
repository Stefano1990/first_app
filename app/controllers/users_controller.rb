class UsersController < ApplicationController
  before_filter :authenticate, :except => [:new, :show, :create]
  before_filter :correct_user, :except => [:index, :new, :show, :create, :destroy]
  before_filter :admin_user, :except => [:index, :new, :show, :edit, :create, :update]
  before_filter :user_is_signed_in, :only => [:new, :create]
  
  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end
  
  def new
    @user = User.new
    @title = "Sign up"
  end
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      @title = "Sign up"
      render 'new'
    end
  end
  
  def edit
    @title = "Edit user"
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end
  
  def destroy
    user_to_destroy = User.find(params[:id])
    unless admin_deletes_himself(user_to_destroy)
      user_to_destroy.destroy
      flash[:success] = "User destroyed."
      redirect_to users_path
    else
      flash[:error] = "You should not delete yourself..."
      redirect_to users_path
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
      
      def user_is_signed_in
        flash[:notice] = "Page unavailable"
        redirect_to(current_user) unless current_user.nil?
      end
      
      def admin_deletes_himself(user)
        current_user.admin? && user.admin? ? true : false
      end
end
