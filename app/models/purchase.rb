class Purchase < ApplicationRecord
  # --- 各カラム バリデーションの設定 ---
  validates :brand, length: { maximum: 30 }, allow_blank: true
  validates :content_quantity, presence: true, numericality: { greater_than: 0 }
  validates :pack_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :tax_rate, presence: true, inclusion: { in: [ 0, 8, 10 ] }
  validates :purchased_on, presence: true

  # --- バリデーション前に実行 ---
  before_validation :normalize_brand

  # --- purchasesのupdateアクション後に実行 ---
  after_update :cleanup_unused_item

  # --- Purchaseモデルのアソシエーション ---
  belongs_to :user
  belongs_to :item
  belongs_to :store, optional: true # store_idがnull許可に変更
  belongs_to :content_unit
  belongs_to :pack_unit, optional: true # pack_unit_idがnull許可に変更

  # --- ransack設定 Purchaseモデルでは直接の属性検索は許可しない ---
  def self.ransackable_attributes(auth_object = nil)
    %w[unit_price purchased_on]
  end

  # --- ransack設定 store関連経由での検索を許可（購入履歴の店舗名絞り込み用） ---
  def self.ransackable_associations(auth_object = nil)
    %w[store]
  end


  private

  # --- 前後の空白削除と空ならnilにする処理 ---
  def normalize_brand
    self.brand = brand&.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")   # 全角半角空白削除
    self.brand = nil if brand.blank? # 空ならnil
  end

  # --- 商品名更新時、更新前の商品名の購入履歴が0件になった場合、削除する処理 ---
  def cleanup_unused_item
    return unless saved_change_to_item_id?
    old_item_id = item_id_before_last_save
    return if Purchase.where(item_id: old_item_id).exists?
    Item.find_by(id: old_item_id)&.destroy
  end
end
