class User < ApplicationRecord
  # --- 各カラム バリデーション設定 ---
  validates :name, presence: true # nil,空,空白禁止
  validates :email, uniqueness: true, unless: :line_user? # nil,空,空白禁止。emailは一意。しかしLINE登録者は対象外。presenceはオーバーライドに任せる。
  validates :provider, inclusion: { in: [ "line" ] }, allow_nil: true # "line"以外の文字は弾く。nilはOK
  validates :uid, presence: true, uniqueness: { scope: :provider }, if: :line_user? # LINE登録者の場合はnil,空,空白禁止で、provider内のuidが一意
  validates :password, format: { without: /\s/, message: "は空白があると登録ができません" }, unless: :line_user? # nil,空,空白禁止。正規表現。しかしline登録者は対象外。presenceはオーバーライドに任せる。

  # --- Userモデルのアソシエーション ---
  has_many :items       # ユーザーは商品レコードを複数持てる
  has_many :stores      # ユーザーは店舗レコードを複数持てる
  has_many :categories  # ユーザーはカテゴリーレコードを複数持てる
  has_many :purchases   # ユーザーは購入履歴レコードを複数持てる

  # --- Devise機能の必要なモジュールを適用 ---
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  # ゲストユーザーとしてログイン時、Userモデルを自動生成。パスワードはランダム
  def self.guest
    find_or_create_by!(name: "ゲストユーザー", email: "guest@example.com") do |user|
      user.password = SecureRandom.alphanumeric(10)
    end
  end

  # LINEログイン経由の登録かどうか確認
  # LINEログイン経由ならtrue。それ以外はfalse。
  def line_user?
    provider == "line"
  end

  # deviseのemail（内部）メソッドを上書き（オーバーライド）
  # !は否定。LINEログイン経由じゃないですよね？ → その場合（true)、emailが必要
  def email_required?
    !line_user?
  end

  # deviseのpassword（内部）メソッドを上書き（オーバーライド）
  # !は否定。LINEログイン経由じゃないですよね？ → その場合（true)、passwordが必要
  def password_required?
    !line_user?
  end
end

##### メモ #####

# Deviseの各モジュールの役割（Github lib/devise/modelsディレクトリ内）
# 1.database_authenticatable
#  パスワード認証に必要な機能を全部まとめたモジュール
#  パスワードをハッシュ化するpassword=メソッド
#  ハッシュ化されたパスワードはencrypted_passwordに保存
#  サインインのパスワードがユーザーのパスワードか検証するvalid_password?メソッドなど


# 2.registerable

# 3.recoverable
#  パスワードのリセット機能

# 4.rememberable
# 　ログイン状態を保持したままにする機能


# 5.validatable
#  emailとpasswordのバリデーションを設定する機能
#  email → presence: true（空白禁止）, uniqueness: true(一意), format（正規表現をメールアドレス形式）
#  password → presence: true（空白禁止）, length（長さconfig.password_lengthで設定）, confirmation（確認用パスワードと一致）
