Rails.application.routes.draw do
  root 'static_pages#home'
  get 'users/new'

  get 'signup'  => 'users#new'
	get 'static_pages/help'

	get 	 'login'	 =>	'sessions/new'
	post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'
	resources :rooms,  :replace_id_with => 'url'
	resources :users

end
