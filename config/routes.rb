WorthReading::Application.routes.draw do

  resources :users do
    resources :emails, only: [:index, :show, :destroy]
    member do
      post :resend_confirm_email
      put :likes
      get :subscribed_to_list
      post :subscribe_me
    end
  end

  resources :emails, only: [:index, :show, :create, :destroy] do
    member do
      get :recipient_list
    end
  end
  resources :sessions, only: [:new, :create, :destroy]
  resources :relationships, only: [:create, :destroy, :index]
  resources :password_resets, only: [:new, :create, :update]

  resources :wr_logs do
    member do
      get :msg_opened
    end
  end

  root to: 'static_pages#home'
  match '/users/:id',  to: 'users#subscribe_to_me'
  match '/users/:id',  to: 'users#subscribe_to_me'
  match '/signup',  to: 'users#new'
  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete
  match '/help',    to: 'static_pages#help'
  match '/about',   to: 'static_pages#about'
  match '/contact', to: 'static_pages#contact'
  match '/email_confirmation', to: 'static_pages#email_confirmation_sent'
  match  '/by_sender', to: 'wr_logs#by_sender'
  match  '/by_receiver', to: 'wr_logs#by_receiver'
  match  '/by_email', to: 'wr_logs#by_email'
 
  match 'wr_logs/:id/msg_opened/:token_identifier', 
    to: 'wr_logs#msg_opened',
    as: :msg_opened
  match 'users/:id/confirm/:confirmation_token', 
    to: 'users#confirm_email', 
    as: :confirm_email
  match 'users/:id/reset_password/:confirmation_token',
    to: 'password_resets#edit', 
    as: :reset_password
  match 'emails/:id/sent_to_subscriber/:receiver_id',
    to: 'emails#emails_sent_to_subscriber',
    as: 'emails_sent_to_subscriber'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
