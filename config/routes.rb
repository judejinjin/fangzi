Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    root to: "root#root", as: "root"
    resources :users do
      resources :properties, only: [:new, :create]
      resources :profiles, only: [:new, :create]
    end
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth" }

  resource :session, only: [:new, :create, :destroy]
  resources :profiles, except: [:new, :create]

  get "/", to: "root#root"

  resources :properties, except: [:new, :create] do
    resources :comments, only: [:new, :create, :edit, :update, :destroy]
    resources :album_photos, except: [:edit, :update]
  end

  get "/index_map", to: "properties#index_map", as: :index_map

  namespace :api, defaults: {format: :json} do
    resources :properties do
      resources :album_photos, except: [:new, :edit]
      resources :comments, except: [:new, :edit]
    end

    post "properties/remove_saved", to: "properties#remove_saved"

    # get "/auth/check_current_user", to: "auth#check_current_user"
  end

end
