# frozen_string_literal: true

# ↑このファイル内の文字列リテラルをすべて「変更不可（freeze）」にする宣言

class DeviseCreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name,               null: false # ニックネーム
      t.string :email,              null: false, default: "" # メールアドレス 値なしを許容しない 既定はDevise公式の設計思想のため空文字
      t.string :encrypted_password, null: false, default: "" # ログイン用パスワード 以下emailに同じ
      t.string   :reset_password_token # パスワード再設定用トークン
      t.datetime :reset_password_sent_at # パスワード再設定メール送信日時
      t.datetime :remember_created_at # ログイン状態保持開始日時
      t.timestamps null: false # 作成日時・更新日時
    end
    # 認証・復旧で検索キーになるカラムのみ、indexを設置
    add_index :users, :email,                unique: true # メールアドレスのindex設置 一意の値
    add_index :users, :reset_password_token, unique: true # パスワード再設定用トークンのindex設置 一意の値
  end
end
