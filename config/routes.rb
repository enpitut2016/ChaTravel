Rails.application.routes.draw do
  root 'static_pages#home'
  get 'users/new'

  get 'signup'  => 'users#new'
	get 'static_pages/help'

 	#TODO よくわからんが動く
	get 	 'login'	 =>	'sessions#new'
	post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'
	resources :rooms,  :replace_id_with => 'url'
	get 'newRoom',to:'static_pages#room_page'

	get :replace_id_with  => 'rooms'
	get ':url', to:'rooms#show'

	resources :users
	get 'user/new'

  post 'rooms/ajax_suggest_request'
end
