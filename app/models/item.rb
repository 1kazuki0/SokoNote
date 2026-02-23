class Item < ApplicationRecord
  # --- nameカラム バリデーションの設定 ---
  validates :name, presence: true,
                   uniqueness: { scope: :category_id },
                   length: { maximum: 30 }

  # --- Itemモデルのアソシエーション ---
  belongs_to :user     # user_idを持つ（ユーザーを参照している）
  belongs_to :category # category_idを持つ（カテゴリーを参照している）
  has_many :purchases  # 複数の購入履歴を参照できる
end
