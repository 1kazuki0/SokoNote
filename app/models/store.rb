class Store < ApplicationRecord
  # --- nameカラムのバリデーションの設定 ---
  validates :name, presence: true,                  # 空白禁止
                   uniqueness: { scope: :user_id }, # 同一ユーザー内で重複禁止
                   length: { maximum: 30 }          # 30文字以内

  # --- バリデーション前に実行 ---
  before_validation :normalize_name

  # --- Storeモデルのアソシエーション ---
  belongs_to :user
  has_many :purchases, dependent: :nullify # store削除時にpurchases.store_idをnil

  private

  # --- 前後の空白削除と空ならnilにする処理 ---
  def normalize_name
    self.name = name&.strip        # 空白削除
    self.name = nil if name.blank? # 空ならnil
  end
end
