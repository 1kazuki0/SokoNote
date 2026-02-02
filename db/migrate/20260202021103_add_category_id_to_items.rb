class AddCategoryIdToItems < ActiveRecord::Migration[7.2]
  def change
    add_reference :items, :category, null: false, foreign_key: true
  end
end
