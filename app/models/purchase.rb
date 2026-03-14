class Purchase < ApplicationRecord
  # --- 各カラム バリデーションの設定 ---
  validates :brand, length: { maximum: 50 }
  validates :content_quantity, presence: true, numericality: { greater_than: 0 }
  validates :content_unit, length: { maximum: 10 }
  validates :pack_quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :pack_unit, length: { maximum: 10 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :tax_rate, presence: true, inclusion: { in: [ 0, 8, 10 ] }
  validates :purchased_on, presence: true

  # --- Itemモデルのアソシエーション ---
  belongs_to :user                  # user_idを持つ（ユーザーを参照している）
  belongs_to :item                  # item_idを持つ（商品を参照している）
  belongs_to :store, optional: true # store_idを持つ（店舗を参照している）, storeがなくてもOK
end
