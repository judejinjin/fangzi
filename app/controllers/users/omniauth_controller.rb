class Users::OmniauthController < Devise::OmniauthCallbacksController

  # facebook callback
  def facebook
    @user = User.create_from_provider_data(request.env['omniauth.auth'])
    if @user.persisted?
      @user.user_profile = Profile.find_by_user_id(@user.id)
      if !@user.user_profile
        @user.user_profile = Profile.new()
        @user.user_profile.user_id = @user.id
        @user.user_profile.save
      end
      #sign_in_and_redirect @user
      login(@user)
      redirect_to user_url(@user)
      #set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
    else
      flash[:error] = 'There was a problem signing you in through Facebook. Please register or try signing in later.'
      redirect_to new_user_registration_url
    end
  end

  # google callback
  def google_oauth2
    @user = User.create_from_provider_data(request.env['omniauth.auth'])
    if @user.persisted?
      @user.user_profile = Profile.find_by_user_id(@user.id)
      if !@user.user_profile
        @user.user_profile = Profile.new()
        @user.user_profile.user_id = @user.id
        @user.user_profile.save
      end
      #sign_in_and_redirect @user
      login(@user)
      redirect_to user_url(@user)
      #set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
    else
      flash[:error] = 'There was a problem signing you in through Google. Please register or try signing in later.'
      redirect_to new_user_registration_url
    end
  end

  # twitter callback
  def twitter
    @user = User.create_from_provider_data(request.env['omniauth.auth'])
    if @user.persisted?
      @user.user_profile = Profile.find_by_user_id(@user.id)
      if !@user.user_profile
        @user.user_profile = Profile.new()
        @user.user_profile.user_id = @user.id
        @user.user_profile.save
      end
      #sign_in_and_redirect @user
      login(@user)
      redirect_to user_url(@user)
      #set_flash_message(:notice, :success, kind: 'Twitter') if is_navigational_format?
    else
      flash[:error] = 'There was a problem signing you in through Twitter. Please register or try signing in later.'
      redirect_to new_user_registration_url
    end
  end

  def failure
    flash[:error] = 'There was a problem signing you in. Please register or try signing in later.'
    redirect_to new_user_registration_url
  end
end
