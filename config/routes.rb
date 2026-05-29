Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  get  "/households/join", to: "households#join_form", as: :join_household
  post "/households/join", to: "households#join"

  resources :households, only: [:new, :create, :show] do
    resources :expenses, only: [:index, :new, :create, :show, :edit, :update]
    resources :settlements, only: [:index, :new, :create]
    resources :balances, only: [:show], param: :user_id
  end

  # Member actions on a specific settlement (confirm/dispute)
  resources :settlements, only: [] do
    member do
      post :confirm
      post :dispute
    end
  end
end
