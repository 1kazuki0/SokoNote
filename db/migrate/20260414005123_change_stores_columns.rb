class ChangeStoresColumns < ActiveRecord::Migration[7.2]
  def change
    change_column_null :stores, :name, false # nameがnull許可からnull禁止に変更
    add_index :stores, [:user_id, :name], unique: true # インデックス追加/同一ユーザー内で重複禁止
  end
end
