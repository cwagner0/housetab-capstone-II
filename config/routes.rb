Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  get  "/households/join", to: "households#join_form", as: :join_household
  post "/households/join", to: "households#join"

  resources :households, only: [:new, :create, :show] do
    resources :expenses, only: [:index, :new, :create, :show]
  end
end
