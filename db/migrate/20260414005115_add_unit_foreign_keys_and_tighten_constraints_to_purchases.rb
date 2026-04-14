class AddUnitForeignKeysAndTightenConstraintsToPurchases < ActiveRecord::Migration[7.2]
  def up
    # ① content_unit_idをNOT NULLに変更（データ移行が完了しているので安全）
    change_column_null :purchases, :content_unit_id, false

    # ② 外部キー制約を追加
    add_foreign_key :purchases, :content_units
    add_foreign_key :purchases, :pack_units, on_delete: :nullify # 親のpack_unitレコードが消されても、purchases.pack_unit_idはnilになる

    # ③ 旧カラムを削除
    remove_column :purchases, :content_unit
    remove_column :purchases, :pack_unit
  end

  def down
    # 旧カラムを復元
    add_column :purchases, :content_unit, :string
    add_column :purchases, :pack_unit, :string

    # 外部キー制約を削除
    remove_foreign_key :purchases, :content_units
    remove_foreign_key :purchases, :pack_units

    # NOT NULL制約を戻す
    change_column_null :purchases, :content_unit_id, true
  end
end
