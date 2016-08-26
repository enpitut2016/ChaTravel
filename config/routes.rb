Rails.application.routes.draw do
  get 'users/new'

  get 'signup'  => 'users#new'
	root 'static_pages#home'
	get 'static_pages/help'
	resources :rooms,  :replace_id_with => 'url'
	resources :users

end
