FirstBargain::Application.routes.draw do

  get 'poller' => 'poller#index'
  get 'poller/:id' => 'poller#show'
  get 'promos' => 'widget#index'
  get 'promos/:id' => "widget#show"
  
  post "orders/ccbill" => "ccbill#create"

  resources :auctions, only: [:index, :show] do
    resources :bids, only: :create
    resource :bid_bot, only: :create
    get :winners, on: :collection
  end

  resources :orders, :except => [:show, :destroy] do
    post :confirm, on: :collection
    get :paypal, on: :collection
    get :success, on: :collection
    get :failure, on: :collection
  end

  resources :bookmarks, only: [:index, :create, :destroy]
  resources :addresses, :except => [:show, :update, :edit]
  resources :invitations, only: [:index, :create]
  get 'bids' => 'bid_packs#new'
  resources :products, only: [:index, :show]
  resources :coupons, only: [:new, :create]
  resources :landings, only: :show do
    get :promo, on: :collection
    get :category, on: :member
  end

  resource :session, only: [:new, :create, :destroy]
  resource :account, :except => :destroy do
    get :welcome
  end
  resource :password_reset, :except => [:destroy, :show]
  resource :contact, only: [:show, :create]
  resource :activation, only: [:new, :create]

  resource :splash, only: [:show, :create]

  namespace :admin do
    resources :featured_auctions, :products, :auctions, :coupons, :categories, :analytics
    resources :orders do
      put :ship, on: :member
      put :void, on: :member
      put :approve, on: :member
      put :refund, on: :member
    end
    resources :accounts do
      put :adjust, on: :member
      put :flag, on: :member
      put :subscribe, on: :member
      get :online, on: :collection
    end
    root :to => "auctions#index"
  end

  get 'privacy' => 'static#privacy'
  get 'about' => 'static#about'
  get 'tutorial' => 'static#tutorial'
  get 'tips' => 'static#tips'
  get 'tos' => 'static#tos'
  get 'returns' => 'static#returns'
  get 'rewards' => 'static#rewards'
  get 'guarantee' => 'static#guarantee'
  get 'rules' => 'static#rules'
  
  get 'faq/new_user' => 'static#faq_new_user'
  get 'faq/auctions' => 'static#faq_auctions'
  get 'faq/account' => 'static#faq_account'
  get 'faq/shipping' => 'static#faq_shipping'
  get 'faq/payment' => 'static#faq_payment'
  get 'faq' => 'static#faq'
  
  root :to => "auctions#index"

end
