class User < ApplicationRecord
  has_many :items       # ユーザーは商品レコードを複数持てる
  has_many :stores      # ユーザーは店舗レコードを複数持てる
  has_many :categories  # ユーザーはカテゴリーレコードを複数持てる
  has_many :purchases   # ユーザーは購入履歴レコードを複数持てる
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
