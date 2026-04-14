class Purchase < ApplicationRecord
  # --- 各カラム バリデーションの設定 ---
validates :brand, length: { maximum: 30 }, allow_blank: true
validates :content_quantity, presence: true, numericality: { greater_than: 0 }
validates :pack_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }
validates :unit_price, presence: true, numericality: { greater_than: 0 }
validates :tax_rate, presence: true, inclusion: { in: [0, 8, 10] }
validates :purchased_on, presence: true

  # --- バリデーション前に実行 ---
  before_validation :normalize_brand


  # --- Itemモデルのアソシエーション ---
  belongs_to :user                  
  belongs_to :item                  
  belongs_to :store, optional: true # store_idがnull許可に変更
  belongs_to :content_unit
  belongs_to :pack_unit, optional: true # pack_unit_idがnull許可に変更

  private

  # --- 前後の空白削除と空ならnilにする処理 ---
  def normalize_brand
    self.brand = brand&.strip        # 空白削除     
    self.brand = nil if brand.blank? # 空ならnil
  end
end
