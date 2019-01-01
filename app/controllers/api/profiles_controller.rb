class Api::ProfilesController < ApplicationController

  def index
    @profiles = Profile.includes(:user).where(user: params[:user_id])

    render :index
  end

  def create
    @profile = current_user.user_profile.new(profile_params)

    @profile.user_id = params[:user_id]
    if @profile.save
      render json: @profile
    else
      render json: @profile.errors.full_messages
    end

  end

  def show
    @profile = Comment.includes(:user).find(params[:id])

    render :show
  end

  def update
    @profile = Profile.find(params[:id])
    if @profile.update(profile_params)
      render json: @profile
    else
      render json: @profile.errors.full_messages
    end
  end

  def destroy

  end

  def profile_params
    params.require(:profile).permit(:name, :brokerage)
  end
end
