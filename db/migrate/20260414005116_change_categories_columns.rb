class ChangeCategoriesColumns < ActiveRecord::Migration[7.2]
  def change
    add_index :categories, [:user_id, :name], unique: true # 同一ユーザー内の重複禁止
  end
end
