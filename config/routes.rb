Rails.application.routes.draw do
	root 'home#index'

	get 'import_information', to: 'home#import_information'
	post 'create_information', to: 'home#create_information'
	# get 'show_information/:hash', to: 'home#show_information'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
