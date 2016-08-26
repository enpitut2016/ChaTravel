Rails.application.routes.draw do
	root 'static_pages#home'
	get 'static_pages/help'
	resources :rooms,  :replace_id_with => 'url'

end
