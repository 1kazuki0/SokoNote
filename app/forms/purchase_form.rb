class PurchaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user_id, :integer
  attribute :category_name, :string
  attribute :item_name, :string
  attribute :store, :string
  attribute :brand, :string
  attribute :content_quantity, :integer
  attribute :content_unit, :string
  attribute :pack_quantity, :integer
  attribute :pack_unit, :string
  attribute :price, :integer
  attribute :unit_price, :decimal
  attribute :tax_rate, :integer
  attribute :purchased_on, :date

  validates :category_name, presence: true, length: { maximum: 30 }
  validates :item_name, presence: true, length: { maximum: 30 }
  validates :store, length: { maximum: 50 }
  validates :brand, length: { maximum: 50 }
  validates :content_quantity, presence: true, numericality: { greater_than: 0 }
  validates :content_unit, length: { maximum: 10 }
  validates :pack_quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :pack_unit, length: { maximum: 10 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :tax_rate, presence: true, inclusion: { in: [ 0, 8, 10 ] }
  validates :purchased_on, presence: true

  # --- ユーザーが入力したpriceを税抜価格で統一 ---
  def price_excluding_tax
    return nil if price.blank? || tax_rate.blank?
    price.to_f / (1 + tax_rate * 0.01)
  end
  # --- 単価計算 ---
  def unit_price_value
    return nil if price_excluding_tax.blank?
    return nil if content_quantity.blank? || pack_quantity.blank?
    price_excluding_tax / content_quantity / pack_quantity
  end

  # --- unit_priceカラムに計算した単価を保存 ---
  def set_unit_price
    self.unit_price = unit_price_value
  end
end
