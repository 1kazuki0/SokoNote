# 商品簡易登録用クラス item_registrationファイル
class ItemRegistrationForm
  # モデルのような機能(:Model)とカラムのような機能(:Attributes)を追加
  # モデルと同じように扱える、属性（カラム）を定義できる
  # before_validationを使用するために記述
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  # --- 1-1.フォームで扱う項目（属性）を定義する ---
  attribute :item_name, :string
  attribute :content_quantity, :decimal
  attribute :content_unit_name, :string
  attribute :price, :integer
  attribute :tax_rate, :integer, default: 0

  # --- 1-2.フォーム外で必要な項目（属性）を定義する ---
  attribute :pack_quantity, :integer, default: 1
  attribute :unit_price, :decimal
  attribute :purchased_on, :date, default: -> { Date.today }

  # --- 2.バリデーションチェック ---
  validates :item_name, presence: true, length: { maximum: 30 }
  validates :content_quantity, presence: true, numericality: { greater_than: 0 }
  validates :content_unit_name, presence: true, length: { maximum: 10 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :tax_rate, presence: true, inclusion: { in: [ 0, 8, 10 ] }
  before_validation :normalize_names

  # ---3.user: コントローラから current_user を代入するため attr_accessor(読み書き両方) ---
  # item, purchase: 読み取り専用で参照するため attr_reader
  attr_accessor :user
  attr_reader :item, :purchase

  # ---4. 保存処理 ---
  def save
    return false unless valid?
    calculated_unit_price = unit_price_value
    ActiveRecord::Base.transaction do
      content_unit = user.content_units.find_or_create_by!(name: content_unit_name)
      @item = user.items.find_or_create_by!(name: item_name)
      @purchase = @item.purchases.create!(
        user: user,
        content_unit_id: content_unit.id,
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
    errors.add(:base, e.record.errors.full_messages.to_sentence)
    false
  rescue ActiveRecord::RecordNotUnique
    errors.add(:base, "同じ名前のデータが既に存在します")
  end

  private

  # normalize_blankメソッドを使用して、item_nameとcontent_unit_nameを適正化
  def normalize_names
    self.item_name = normalize_blank(item_name)
    self.content_unit_name = normalize_blank(content_unit_name)
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
