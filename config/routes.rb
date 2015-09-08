Rails.application.routes.draw do
  get 'password_resets/new'

  get 'password_resets/edit'

  root                'static_pages#home'     #root_path
  get    'help'    => 'static_pages#help'     #help_path
  get    'about'   => 'static_pages#about'    #about_path
  get    'contact' => 'static_pages#contact'  #contact_path
  get    'signup'  => 'users#new'             #signup_path

  # Sessions (not a complete RESTful resource)
  get    'login'   => 'sessions#new'          #login_path
  post   'login'   => 'sessions#create'       #login_path
  delete 'logout'  => 'sessions#destroy'      #logout_path
  
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :users 
  # Makes Users a RESTful resource, generating all the following routes:
  # METHOD  URL            ACTION
  # [GET]   /users       : index
  # [GET]   /users/1     : show
  # [GET]   /users/new   : new
  # [POST]  /users       : create
  # [GET]   /users/1/edit: edit
  # [PATCH] /users/1     : update 
  # [DELETE]/users/1     : destroy




  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
