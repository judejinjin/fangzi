class ProfilesController < ApplicationController

  def new
    @profile = current_user.user_profile.new(profile_params)
    @profile.user_id = current_user.id
    if @profile.save
      render :show
    else
      flash.now[:errors] = @profile.errors.full_messages
      render :edit
    end
  end

  def create
    @profile = current_user.user_profile.new(profile_params)
    @profile.user_id = current_user.id
    if @profile.save
      render :show
    else
      flash.now[:errors] = @profile.errors.full_messages
      render :edit
    end

  end

  def edit
    @profile = current_user.user_profile
    if @profile
      render :edit
    else
      render json: "Profile not found"
    end
  end

  def update
    @profile = current_user.user_profile
    if @profile.update(profile_params)
      render :show
    else
      flash.now[:errors] = @profile.errors.full_messages
      render :edit
    end
  end

  def destroy
    render json: "Profile cannot be deleted"
  end

  def profile_params
    params.require(:profile).permit(:name, :brokerage,:phone,:emailcontact)
  end
end
