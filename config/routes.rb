Rails.application.routes.draw do
  # gem devise導入時に生成
  devise_for :users 
  
  # 未ログイン時のトップ画面
  root "home#top"
  
  # 商品一覧・登録（ウィザード形式 / 商品もカテゴリも新しく作る場合）
  # step1：基本情報入力, step2：詳細入力, session：基本情報入力値の一時保持
  resources :items do
    collection do
      get :new_step1
      get :new_step2
      post :save_new_step1
    end
  end

  # 購入履歴詳細・編集・購入履歴登録（ウィザード形式 / 商品・カテゴリは既に決まっていて作る場合）
  # step1：基本情報入力, step2：詳細入力, session：基本情報入力値の一時保持
  resources :purchases do
    collection do
      get :new_step1
      get :new_step2
      post :session
    end
  end
      
  # 設定画面
  get "setting", to: "setting#index"

  # --- 以下は現状非設定 ---

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
