Rails.application.routes.draw do
  devise_for :supplier_staffs, path: :supplier, :controllers => {
    :passwords => "supplier/passwords",
    :sessions => "supplier/sessions",
    :unlocks => "supplier/unlocks"
  }

  namespace 'supplier', path: nil do
    namespace 'control_panel', path: :scp do
      get '/' => 'dashboard#index'
      get 'dashboard' => 'dashboard#index',
          as: :dashboard
      get 'coming_soon' => 'pages#coming_soon',
          as: :coming_soon
      resource :my_account, controller: 'my_account'
      resources :books
    end
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  root 'books#index'

  get '/index' => 'pages#index', as: :new_user_session
  get '/faq' => 'pages#faq'
  get '/flow' => 'pages#flow'
  get '/flow/buy' => 'pages#shopping_flow_buy'
  get '/flow/deliver' => 'pages#shopping_flow_deliver'
  get '/flow/mainchew' => 'pages#shopping_flow_mainchew'
  get '/paymethod' => 'pages#paymethod'
  get '/paymethod/711' => 'pages#paymethod_711'
  get '/paymethod/famiport' => 'pages#paymethod_famiport'
  get '/paymethod/life' => 'pages#paymethod_life'
  get '/paymethod/ok' => 'pages#paymethod_ok'

  resource :my_account, controller: 'users/my_account' do
    get 'invoice_subsume' => 'users/my_account#invoice_subsume'
  end

  resources :lecturer do
    resources :courses, controller: :lecturer_courses
  end

  resources :course_books

  resources :book_datas

  resources :books

  resources :cart_items

  resources :bills

  resources :courses

  resources :groups

  post '/my-account' => 'users/my_account#invoice_subsume_confirm'
  post '/invoice_subsume_confirm' => 'users/my_account#invoice_subsume_confirm'

  get '/tasks/payment_code_check' => 'tasks#payment_code_check'

  get '/sorry_but_forbidden' => 'pages#sorry_but_forbidden'

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
