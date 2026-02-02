class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.string :name, null: false # 商品名 値なしを許容しない
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
