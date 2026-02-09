class Purchase < ApplicationRecord
  validates :content_quantity, presence: true
  validates :pack_quantity, presence: true
  validates :price, presence: true

  belongs_to :user  # user_idを持つ（ユーザーを参照している）
  belongs_to :item  # item_idを持つ（商品を参照している）
  belongs_to :store # store_idを持つ（店舗を参照している）
end
