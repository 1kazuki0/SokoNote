class Category < ApplicationRecord
  # --- nameカラム バリデーションの設定 ---
  validates :name, presence: true, length: { maximum: 30 }, uniqueness: { scope: :user_id }
  
  # --- バリデーション前に実行 ---
  before_validation :normalize_name

  # --- Categoryモデルのアソシエーション ---
  belongs_to :user
  has_many :items, dependent: :nullify

  private

  # --- 前後の空白削除と空ならnilにする処理 ---
  def normalize_name
    self.name = name&.strip        # 空白削除     
    self.name = nil if name.blank? # 空ならnil
  end
end
