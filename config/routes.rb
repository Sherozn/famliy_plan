Rails.application.routes.draw do
	root 'home#index'

	get 'import_information', to: 'home#import_information'
	post 'create_information', to: 'home#create_information'
	get 'new_note/:ins_id/:name', to: 'home#new_note'
	post 'create_note', to: 'home#create_note'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
