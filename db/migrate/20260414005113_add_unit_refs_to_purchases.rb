class AddUnitRefsToPurchases < ActiveRecord::Migration[7.2]
  def change
    add_column :purchases, :content_unit_id, :bigint # 単位（内容量）のid追加（この時点ではnull許可）
    add_column :purchases, :pack_unit_id, :bigint # パック単位のid追加

    # インデックス追加
    add_index :purchases, :content_unit_id
    add_index :purchases, :pack_unit_id
  end
end
