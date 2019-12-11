Rails.application.routes.draw do
  devise_for :users
  
  root to: "home#index"
  get 'home/index'

  resources :activity_types
  resources :activities
  
  get 'about', to: "about_contact#about"
  get 'contact', to: "about_contact#contact"
end
