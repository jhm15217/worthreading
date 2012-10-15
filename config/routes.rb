WorthReading::Application.routes.draw do

  resources :users do
    resources :emails, only: [:index, :show, :destroy]
    member do
      get :edit_email
      get :subscribed_to_list
      get :received
      get :confirm_email_change
      put :likes
      post :resend_confirm_email
      post :subscribe_me
      post :subscribe_to_me
      delete :unsubscribe_me
      delete :unsubscribe_to_me
    end
  end

  resources :emails, only: [:index, :show, :create, :destroy] do
    member do
      get :recipient_list
    end
  end

  resources :relationships, only: [:create, :destroy, :index] do
    member do 
      get :email_unsubscribe 
      delete :unsubscribe_from_mailing_list
    end
  end

  resources :sessions, only: [:new, :create, :destroy]
  resources :password_resets, only: [:new, :create, :update]

  resources :wr_logs do
    member do
      get :msg_opened
      get :follow
    end
  end

  root to: 'static_pages#home'
  match '/signup',  to: 'users#new'
  match '/failure', to: 'users#failure'
  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete
  match '/help',    to: 'static_pages#help'
  match '/about',   to: 'static_pages#about'
  match '/contact', to: 'static_pages#contact'
  match '/email_confirmation', to: 'static_pages#email_confirmation_sent'
  match  '/by_sender', to: 'wr_logs#by_sender'
  match  '/by_receiver', to: 'wr_logs#by_receiver'
  match  '/by_email', to: 'wr_logs#by_email'
  match '/whats_this', to: 'static_pages#whats_this'
  match '/add_sources', to: 'relationships#add_sources'
  match '/compose_new', to: 'emails#compose_new'
  match '/compose', to: 'emails#compose'

  match 'wr_logs/:id/msg_opened/:token_identifier', 
    to: 'wr_logs#msg_opened',
    as: :msg_opened
  match 'wr_logs/:id/follow/:token_identifier',
    to: 'wr_logs#follow',
    as: :follow
  match 'users/:id/confirm/:confirmation_token',
    to: 'users#confirm_email', 
    as: :confirm_email
  match 'users/:id/reset_password/:confirmation_token',
    to: 'password_resets#edit', 
    as: :reset_password
  match 'emails/:id/sent_to_subscriber/:receiver_id',
        to: 'emails#emails_sent_to_subscriber',
        as: 'emails_sent_to_subscriber'

  # Extension Routes
  match 'chrome_extension/new', to: 'chrome_extension#new' 
  match 'firefox_extension/new', to: 'chrome_extension#new' 
  post 'chrome_extension', to: 'chrome_extension#create'
  post 'firefox_extension', to: 'chrome_extension#create'

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
