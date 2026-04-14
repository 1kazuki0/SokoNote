class CreateContentUnits < ActiveRecord::Migration[7.2]
  def change
    create_table :content_units do |t|
      t.references :user, null: false, foreign_key: true # null禁止/外部キー参照
      t.string :name, null: false                        # null禁止
      t.timestamps
    end

    add_index :content_units, [ :user_id, :name ], unique: true # インデックス追加/同一ユーザー内のnameカラムの重複禁止
  end
end
