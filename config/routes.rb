Rails.application.routes.draw do
  resources :expenses
  resources :incomes
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"

  get "check_deploy", controller: 'application'
end
