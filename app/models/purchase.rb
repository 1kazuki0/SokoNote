class Purchase < ApplicationRecord
  # --- 各カラム バリデーションの設定 ---
  validates :brand, length: { maximum: 50 }
  validates :content_quantity, presence: true, numericality: { greater_than: 0 }
  validates :content_unit, length: { maximum: 10 }
  validates :pack_quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :pack_unit, length: { maximum: 10 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :tax_rate, presence: true, inclusion: { in: [0, 8, 10] }
  validates :purchased_on, presence: true

  # --- Itemモデルのアソシエーション ---
  belongs_to :user  # user_idを持つ（ユーザーを参照している）
  belongs_to :item  # item_idを持つ（商品を参照している）
  belongs_to :store # store_idを持つ（店舗を参照している）

  # --- ユーザーが入力したpriceを税抜価格で統一 ---
  def price_excluding_tax
    return nil if price.blank? || tax_rate.blank?
    price / ( 1 + tax_rate / 100.0)
  end
  # --- 単価計算 ---
  def unit_price_value
    return nil if price_excluding_tax.blank?
    return nil if content_quantity.blank? || pack_quantity.blank?
    total_quantity = content_quantity * pack_quantity
    return nil if total_quantity <= 0
    price_excluding_tax / total_quantity
  end

  private
  def set_unit_price
    self.unit_price = unit_price_value
  end
end
