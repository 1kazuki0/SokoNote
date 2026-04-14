class ChangeItemsColumns < ActiveRecord::Migration[7.2]
  def change
    change_column_null :items, :category_id, true            # category_idがnull禁止からnull許可に変更
    remove_foreign_key :items, :categories                   # 外部制約を一度解除する
    add_foreign_key :items, :categories, on_delete: :nullify # 親のcategoryレコードが消されても、items.category_idはnil
    add_index :items, [:user_id, :name], unique: true        # インデックス追加/同一ユーザー内の重複禁止
  end
end
