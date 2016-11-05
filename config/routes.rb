Rails.application.routes.draw do
  resources :raw_words
  resources :social_nodes
  get 'home/index'

  resources :hist_friends
  resources :word_friends
  resources :words
  resources :histograms
  resources :word_lengths
  get 'hello_world/index'
  # root 'hello_world#index'
  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
