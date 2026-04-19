class Item < ApplicationRecord
  # --- nameカラム バリデーションの設定 ---
  validates :name, presence: true,                  # 空白禁止
                   uniqueness: { scope: :user_id }, # 同一ユーザー内で重複禁止
                   length: { maximum: 30 }          # 30文字以内

  # --- バリデーション前に実行 ---
  before_validation :normalize_name

  # --- Itemモデルのアソシエーション ---
  belongs_to :user
  belongs_to :category, optional: true     # category_idがnull許可に変更
  has_many :purchases, dependent: :destroy # item削除時にpurchasesも削除

  private

  # --- 前後の空白削除と空ならnilにする処理 ---
  def normalize_name
    self.name = name&.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")   # 全角半角空白削除
    self.name = nil if name.blank?                                # 空ならnil
  end
end
