class Api::V1::UsersController < ApplicationController
  skip_before_action :logged_in?, only: [:create]
  before_action :find_user, only: [:show, :update]
  def create
    user = User.new(user_params)
    options = {include: [:messages]}
    if user.save
      render json: {user: UserSerializer.new(user, option).serializable_hash, token: encode_token({user_id: user.id})}
    else
      render json: {errors: "OH NO! > o < "}
    end
  end

  def show
    user = User.find(params[:id])
    options = {include: [:messages]}
    render json: {user: UserSerializer.new(user, options).serializable_hash, token: encode_token({user_id: user.id})}
  end

  def update
    user.update(user_params)
    options = {include: [:messages]}
    render json: {user: UserSerializer.new(user, options).serializable_hash, token: encode_token({user_id: user.id})}
  end

  private 

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :seeking, :bio, :location, :img_url)
  end

  def find_user
    user = User.find(params[:id])
  end

end
