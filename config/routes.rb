Rails.application.routes.draw do
  devise_for :users # controller: { registrations: 'users/registrations' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # 未ログイン時のトップ画面の仮設定
  root "home#top"
  # ログイン後のホーム画面（商品一覧画面）の設定
  resources :items
  # 設定画面
  get 'setting', to: "setting#index"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
