Rails.application.routes.draw do
  # devise認証, コントローラー修正箇所だけルーティング追記
  devise_for :users, controllers: {
    registrations: "users/registrations",
    passwords: "users/passwords",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # ゲストユーザー用
  devise_scope :user do
    post "users/guest_sign_in", to: "users/sessions#guest_sign_in"
  end

  # 未ログイン時のトップ画面
  root "home#top"

  # 商品簡易登録用
  resource :item_registration, only: [ :new, :create ]

  # カテゴリ一覧・登録・編集・削除
  resources :categories, except: [ :show ]

  # 店舗一覧・登録・編集・削除
  resources :stores, except: [ :show ]

  # 内容量単位一覧・登録・編集・削除
  resources :content_units, except: [ :show ]

  # 商品一覧・登録（ウィザード形式 / 商品もカテゴリも新しく作る場合）
  resources :items do
    resources :purchases, only: [:index, :edit, :update, :destroy]
  end

  # 単価比較画面
  get "comparison", to: "comparison#index"
  # 設定画面
  get "setting", to: "setting#index"

  # letter_opener_webのルーティング
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # --- 以下は現状非設定 ---

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
