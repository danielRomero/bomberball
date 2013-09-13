Bomberball::Application.routes.draw do
  
  devise_for :users
  
  root 'landing#index'

  get 'users/login_beperk' =>'users#login_beperk', as: :login_beperk
  get 'users/login_twitter' =>'users#login_twitter', as: :login_twitter
  post 'users/login_twitter' =>'users#login_twitter', as: :login_twitter_post
  get 'users/login_google' =>'users#login_google', as: :login_google
  get 'users/login_facebook' =>'users#login_facebook', as: :login_facebook
  delete 'users/sign_out' => 'users#user_sign_out', as: :user_sign_out

  get 'landing/about_me' => 'landing#about_me', as: :about_me
  
  # ---------------------------------------- !!!!!!!!!!!!!!!! BORRAME ---------------------------------------- !!!!!!!!!!!!!!!!
  get 'users/entrar' =>'users#entrar', as: :entrar


  resources :games
  resources :users
  resources :profiles
  resources :privacy_license_and_terms
  
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
