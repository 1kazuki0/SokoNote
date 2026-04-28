# 商品詳細入力用クラス purchase_updateファイル
class PurchaseUpdateForm
  # モデルのような機能(:Model)とカラムのような機能(:Attributes)を追加
  # モデルと同じように扱える、属性（カラム）を定義できる
  # before_validationを使用するために記述
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  # --- 1-1.フォームで扱う項目（属性）を定義する ---
  attribute :category_name, :string
  attribute :item_name, :string
  attribute :brand, :string
  attribute :content_quantity, :decimal
  attribute :content_unit_name, :string
  attribute :pack_quantity, :integer, default: 1
  attribute :pack_unit_name, :string
  attribute :store_name, :string
  attribute :purchased_on, :date, default: -> { Date.today }
  attribute :price, :integer
  attribute :tax_rate, :integer, default: 0

  # --- 1-2.フォーム外で必要な項目（属性）を定義する ---
  attribute :unit_price, :decimal

  # --- 2.バリデーションチェック ---
  validates :category_name, length: { maximum: 30 }, allow_blank: true
  validates :item_name, presence: true, length: { maximum: 30 }
  validates :brand, length: { maximum: 30 }, allow_blank: true
  validates :content_quantity, presence: true, numericality: { greater_than: 0 }
  validates :content_unit_name, presence: true, length: { maximum: 10 }
  validates :pack_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :pack_unit_name, length: { maximum: 10 }, allow_blank: true
  validates :store_name, length: { maximum: 30 }, allow_blank: true
  validates :purchased_on, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :tax_rate, presence: true, inclusion: { in: [ 0, 8, 10 ] }
  before_validation :normalize_names

  # ---3. current_userを使用するための記述 ---
  attr_accessor :user, :purchase

  # ---4. 更新処理 ---
  def update
    return false unless valid?
    calculated_unit_price = unit_price_value
    ActiveRecord::Base.transaction do
      category = category_name.present? ? user.categories.find_or_create_by!(name: category_name) : nil
      store = store_name.present? ? user.stores.find_or_create_by!(name: store_name) : nil
      content_unit = user.content_units.find_or_create_by!(name: content_unit_name)
      pack_unit = pack_unit_name.present? ? user.pack_units.find_or_create_by!(name: pack_unit_name) : nil
      item = user.items.find_or_create_by!(name: item_name)
      item.update!(category: category)
      purchase.update!(
        item: item,
        store: store,
        content_unit: content_unit,
        pack_unit: pack_unit,
        brand: brand,
        content_quantity: content_quantity,
        pack_quantity: pack_quantity,
        price: price,
        tax_rate: tax_rate,
        unit_price: calculated_unit_price,
        purchased_on: purchased_on
      )
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.record.errors.full_messages.join(", "))
    false
  rescue ActiveRecord::RecordNotUnique
    errors.add(:base, "同じ名前のデータが既に存在します")
    false
  end

  private

  # normalize_blankメソッドを使用して、各カラムを適正化
  def normalize_names
    self.category_name = normalize_blank(category_name)
    self.item_name = normalize_blank(item_name)
    self.content_unit_name = normalize_blank(content_unit_name)
    self.pack_unit_name = normalize_blank(pack_unit_name)
    self.store_name = normalize_blank(store_name)
    self.brand = normalize_blank(brand)
  end

  # ---　前後空白を削除し、空ならnilにする処理 ---
  def normalize_blank(value)
    value = value&.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")   # 全角半角空白削除
    value.presence
  end

  # ===== 商品の単価計算ロジック =====
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
end
