class Category < ApplicationRecord
  # --- nameカラム バリデーションの設定 ---
  validates :name, presence: true, length: { maximum: 30 }, uniqueness: { scope: :user_id }

  # --- バリデーション前に実行 ---
  before_validation :normalize_name

  # --- Categoryモデルのアソシエーション ---
  belongs_to :user
  has_many :items, dependent: :nullify

  # --- ransack設定 Categoryモデルのidカラムのみ検索許可（商品一覧でのカテゴリ絞り込み用） ---
  def self.ransackable_attributes(auth_object = nil)
    %w[id]
  end

  private

  # --- 前後の空白削除と空ならnilにする処理 ---
  def normalize_name
    self.name = name&.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")   # 全角半角空白削除
    self.name = nil if name.blank?                                # 空ならnil
  end
end
