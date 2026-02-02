class CreatePurchases < ActiveRecord::Migration[7.2]
  def change
    create_table :purchases do |t|
      t.string :brand # ブランド名・メーカー名
      t.integer :content_quantity, null: false # 内容量　値なしを許容しない
      t.string :content_unit # 内容量の単位
      t.integer :pack_quantity, null: false # パック数・セット数
      t.string :pack_unit # パック数・セット数の単位
      t.integer :price, null: false # ユーザーが入力した価格
      t.decimal :unit_price, precision: 8, scale: 2 # 計算後の価格（税抜で統一）数値全体の桁数「8桁」小数点第2まで
      t.integer :tax_rate, null: false, default: 0 # 消費税 0（税抜）を前提デフォルトで設定
      t.references :user,  null: false, foreign_key: true
      t.references :store, null: false, foreign_key: true
      t.references :item,  null: false, foreign_key: true
      t.timestamps
    end
  end
end
