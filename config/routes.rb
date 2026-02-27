Rails.application.routes.draw do
  devise_for :users

  # Admin namespace (admin + team_leader only)
  namespace :admin do
    get "dashboard", to: "dashboard#index"
    resources :groups
    resources :coders, only: [ :index ] do
      collection do
        post :import
      end
    end
    resources :teams, only: [ :index, :show, :new, :create, :destroy ] do
      collection do
        post :create_multiple_github_repos
      end
      member do
        get :qr
        post :create_github_repo
      end
    end
  end

  # Portal namespace (coder users)
  namespace :portal do
    get "dashboard", to: "dashboard#index"
    resources :teams, only: [ :new, :create, :show, :edit, :update ]
  end

  # Public team registration via QR token
  get "register/:token", to: "team_registrations#new", as: :team_registration
  post "register/:token", to: "team_registrations#create"

  # API endpoints
  namespace :api do
    get "coders/search", to: "coders#search"
    get "coders/search_safe", to: "coders#search_safe"
    get "coders/check_team", to: "coders#check_team"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Role-based root paths
  authenticated :user, ->(u) { u.admin? || u.team_leader? } do
    root "admin/dashboard#index", as: :admin_root
  end

  authenticated :user do
    root "portal/dashboard#index", as: :portal_root
  end

  root to: redirect("/users/sign_in")
end
