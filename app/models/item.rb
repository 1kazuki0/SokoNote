class Item < ApplicationRecord
  belongs_to :user     # user_idを持つ（ユーザーを参照している）
  belongs_to :category # category_idを持つ（カテゴリーを参照している）
  has_many :purchases  # 複数の購入履歴を参照できる
end
