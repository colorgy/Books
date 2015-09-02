Rails.application.routes.draw do
  devise_for :supplier_staffs, path: :supplier, :controllers => {
    :passwords => "supplier/passwords",
    :sessions => "supplier/sessions",
    :unlocks => "supplier/unlocks"
  }

  namespace 'lecturer_books', path: 'lecturer-books' do
    get '/' => 'lecturer_books#index'
    resources :organization_selections
    resources :lecturer_selections
    resources :book_data_selections
    resources :courses
    put 'courses' => 'courses#update_courses'
  end

  namespace 'course_books', path: 'course-books' do
    get '/' => 'course_books#index'
    resources :organization_selections
    resources :lecturer_selections
    resources :book_data_selections
    resources :courses
    put 'courses' => 'courses#update_courses'
  end

  namespace 'course_books', path: 'course-books/:code' do
    get '/' => 'course_books#index'
    resources :organization_selections
    resources :lecturer_selections
    resources :book_data_selections
    resources :courses
    put 'courses' => 'courses#update_courses'
  end

  namespace 'supplier', path: nil do
    namespace 'control_panel', path: :scp do
      get '/' => 'dashboard#index'
      get 'dashboard' => 'dashboard#index',
          as: :dashboard
      get 'coming_soon' => 'pages#coming_soon',
          as: :coming_soon
      resource :my_account, controller: 'my_account'
      resources :books
      resources :deliver
    end
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  authenticated :user do
    root 'books#index'
  end

  root 'pages#index', as: :new_user_session

  get '/shopping-guide' => 'pages#shopping_guide'
  get '/faq' => 'pages#faq'
  get '/guide' => 'pages#guide'
  get '/payments' => 'pages#payments'
  get '/paymethods' => 'pages#payments'
  get '/flow' => 'pages#flow'
  get '/flow/buy' => 'pages#shopping_flow_buy'
  get '/flow/deliver' => 'pages#shopping_flow_deliver'
  get '/flow/mainchew' => 'pages#shopping_flow_mainchew'
  get '/paymethod' => 'pages#paymethod'
  get '/paymethod/711' => 'pages#paymethod_711'
  get '/paymethod/famiport' => 'pages#paymethod_famiport'
  get '/paymethod/life' => 'pages#paymethod_life'
  get '/paymethod/ok' => 'pages#paymethod_ok'

  get '/sponsors' => 'sponsors#index'
  get '/sponsors/taiwan-mobile' => 'sponsors#taiwan-mobile'

  resource :my_account, controller: 'users/my_account' do
    get 'invoice_subsume' => 'users/my_account#invoice_subsume'
  end

  resources :lecturer do
    resources :courses, controller: :lecturer_courses
  end

  resources :course_books

  resources :book_datas

  resources :books
  get 'books_search_suggestions' => 'books#search_suggestions'

  resources :cart_items
  resources :orders

  resources :bills
  resources :credits

  get 'user_course_books/edit' => 'user_course_books#edit'
  resources :user_course_books

  resources :courses

  resources :groups

  resources :feedbacks

  resources :book_selections
  resources :course_selections

  post '/my-account' => 'users/my_account#invoice_subsume_confirm'
  post '/invoice_subsume_confirm' => 'users/my_account#invoice_subsume_confirm'

  get '/tasks/payment_code_check' => 'tasks#payment_code_check'

  get '/sorry_but_forbidden' => 'pages#sorry_but_forbidden'

  get '/not_open_for_orders' => 'pages#not_open_for_orders'

  require 'sidekiq/web'
  authenticate :user, ->(u) { u.present? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get '/pay/credit_card/pay_redirect/:id' => 'bills#credit_card_pay_redirect', as: 'credit_card_pay_redirect'
  get '/pay/credit_card/success' => 'bills#credit_card_success'
  get '/pay/credit_card/fail' => 'bills#credit_card_fail'
  get '/pay/credit_card/callback' => 'bills#credit_card_callback'

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
