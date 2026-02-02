class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false # カテゴリー名 値なしを許容しない
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
