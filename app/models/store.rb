class Store < ApplicationRecord
  belongs_to :user    # user_idを持つ（ユーザーを参照している）
  has_many :purchases # 店舗は購入履歴レコードを複数持てる
end
