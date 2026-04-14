class MigrateUnitDataToPurchases < ActiveRecord::Migration[7.2]
  def up
    # ① content_unitsテーブルにデータを移行
    execute(<<~SQL)
      INSERT INTO content_units (user_id, name, created_at, updated_at)
      SELECT DISTINCT user_id, TRIM(content_unit), NOW(), NOW()
      FROM purchases
      WHERE content_unit IS NOT NULL AND TRIM(content_unit) != ''
      ON CONFLICT (user_id, name) DO NOTHING
    SQL

    # ② pack_unitsテーブルにデータを移行
    execute(<<~SQL)
      INSERT INTO pack_units (user_id, name, created_at, updated_at)
      SELECT DISTINCT user_id, TRIM(pack_unit), NOW(), NOW()
      FROM purchases
      WHERE pack_unit IS NOT NULL AND TRIM(pack_unit) != ''
      ON CONFLICT (user_id, name) DO NOTHING
    SQL

    # ③ purchases.content_unit_idにIDをセット
    execute(<<~SQL)
      UPDATE purchases
      SET content_unit_id = content_units.id
      FROM content_units
      WHERE purchases.user_id = content_units.user_id
        AND TRIM(purchases.content_unit) = content_units.name
    SQL

    # ④ purchases.pack_unit_idにIDをセット
    execute(<<~SQL)
      UPDATE purchases
      SET pack_unit_id = pack_units.id
      FROM pack_units
      WHERE purchases.user_id = pack_units.user_id
        AND TRIM(purchases.pack_unit) = pack_units.name
    SQL
  end

  def down
    # ロールバック時はIDをクリアしてテーブルのデータを削除
    execute("UPDATE purchases SET content_unit_id = NULL, pack_unit_id = NULL")
    execute("DELETE FROM pack_units")
    execute("DELETE FROM content_units")
  end
end