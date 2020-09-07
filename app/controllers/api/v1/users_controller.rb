class Api::V1::UsersController < ApplicationController
  skip_before_action :logged_in?, only: [:create, :update]
  before_action :find_user, only: [:show, :update]
  
  def index
    users = User.all 
    render json: UserSerializer.new(users).serializable_hash
  end
  
  def create
    user = User.new(user_params)
    if user.save
      render json: {user: UserSerializer.new(user).serializable_hash, token: encode_token({user_id: user.id})}
    else
      render json: {errors: "OH NO! > o < "}
    end
  end

  def show
    user = User.find(params[:id])
    options = {include: [:match_chats, :songs]}
    render json: {user: UserSerializer.new(user, options).serializable_hash, token: encode_token({user_id: user.id})}
  end

  def update
    byebug
    user = User.find(params[:id])
    if params[:profile_picture]
      user.profile_picture.attach(params[:profile_picture])
      photo = url_for(user.profile_picture)
      user.update(img_url: photo)
    else
      user.update(user_params)
      render json: {user: UserSerializer.new(user).serializable_hash, token: encode_token({user_id: user.id})}
    end
  end

  def query
    filtered_users = User.all.select{|user| (user.genre_ids & params[:genreFilters]).any? }
    options = options = {include: [:songs]}
    render json: UserSerializer.new(filtered_users, options).serializable_hash
  end

  private 

  def user_params
    params.require(:user).permit(:first_name, :last_name, :profile_picture, :email, :password, :password_confirmation, :narrative, :bio, :location, :img_url)
  end

  def find_user
    user = User.find(params[:id])
  end

end
