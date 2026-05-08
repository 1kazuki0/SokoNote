Rails.application.routes.draw do
  # devise認証, コントローラー修正箇所だけルーティング追記
  devise_for :users, controllers: {
    registrations: "users/registrations",
    passwords: "users/passwords",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # 未ログイン時のトップ画面
  root "home#top"

  # 商品簡易登録用（登録用new・create・完了ダイアログcomplete・自動補助入力last_purchase）
  resource :item_registration, only: [ :new, :create ] do
    get :complete, :last_purchase
  end

  # カテゴリ一覧・登録・編集・削除
  resources :categories, except: [ :show ]

  # 店舗一覧・登録・編集・削除
  resources :stores, except: [ :show ]

  # 単位（内容量）一覧・登録・編集・削除
  resources :content_units, except: [ :show ]

  # 商品一覧・購入履歴用（一覧・削除 / 一覧・編集・削除）
  resources :items, only: [ :index, :destroy ] do
    resources :purchases, only: [ :index, :edit, :update, :destroy ]
  end

  # 単価比較画面
  get "comparison", to: "comparison#index"
  # 設定画面
  get "setting", to: "setting#index"

  # 利用規約画面
  get "terms", to: "terms#index"

  # プライバシーポリシー
  get "privacy_policy", to: "privacy_policy#index"

  # letter_opener_web のルーティング
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # ヘルスチェック用エンドポイント。/upで確認（正常200,例外500）
  get "up" => "rails/health#show", as: :rails_health_check

  # --- 以下は現状非設定 ---

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
