Rails.application.routes.draw do
	get 'users/new'
	get 'signup'  => 'users#new'
	root 'static_pages#home'
	get 'static_pages/help'
	get 'newRoom',to:'static_pages#room_page'
	resources :rooms,  :replace_id_with => 'url'

	get :replace_id_with  => 'rooms'
	get ':url', to:'rooms#show'

	resources :users
	get 'user/new'

end
