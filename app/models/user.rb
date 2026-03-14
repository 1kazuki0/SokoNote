class User < ApplicationRecord
  
  # --- 各カラム バリデーション設定 ---
  validates :name, presence: true # nil,空,空白禁止
  validates :password, format: { without: /\s/, message: "は空白があると登録ができません" }
  
  # --- Userモデルのアソシエーション ---
  has_many :items       # ユーザーは商品レコードを複数持てる
  has_many :stores      # ユーザーは店舗レコードを複数持てる
  has_many :categories  # ユーザーはカテゴリーレコードを複数持てる
  has_many :purchases   # ユーザーは購入履歴レコードを複数持てる
  
  # Devise機能の必要なモジュールを適用
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable
end

##### メモ #####

# Deviseの各モジュールの役割（Github lib/devise/modelsディレクトリ内）
# 1.database_authenticatable
#  パスワード認証に必要な機能を全部まとめたモジュール
#  パスワードをハッシュ化するpassword=メソッド
#  ハッシュ化されたパスワードはencrypted_passwordに保存
#  サインインのパスワードがユーザーのパスワードか検証するvalid_password?メソッドなど


# 2.registerable
# 

# 3.recoverable
#  パスワードのリセット機能

# 4.rememberable
# 　ログイン状態を保持したままにする機能
#   

# 5.validatable
#  emailとpasswordのバリデーションを設定する機能
#  email → presence: true（空白禁止）, uniqueness: true(一意), format（正規表現をメールアドレス形式）
#  password → presence: true（空白禁止）, length（長さconfig.password_lengthで設定）, confirmation（確認用パスワードと一致）
# 

