class Category < ApplicationRecord
  # --- nameカラム バリデーションの設定 ---
  validates :name, presence: true,
                   uniqueness: { scope: :user_id },
                   length: { maximum: 30 }

  # --- Categoryモデルのアソシエーション ---
  belongs_to :user
  has_many :items
end
