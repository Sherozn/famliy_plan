Rails.application.routes.draw do
	root 'home#index'
	get 'signup' => 'accounts#signup'
  get 'login' => 'accounts#login'
  post 'create_account' => 'accounts#create_account'
  post 'create_login' => 'accounts#create_login'
  delete 'logout' => "accounts#logout"
  get 'account_active' => 'accounts#account_active'
  get 'update_active/:account_id' => 'accounts#update_active'

	get 'import_information', to: 'home#import_information'
	post 'create_information', to: 'home#create_information'
	get 'new_note/:ins_id/:ill_id', to: 'home#new_note'
	post 'create_note', to: 'home#create_note'
	get 'derive', to: 'home#derive'
	get 'down_rate', to: 'home#down_rate'


	get 'add_note', to: 'home#add_note'
	get 'search_product', to: "home#search_product"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
