class AddPurchasedOnToPurchases < ActiveRecord::Migration[7.2]
  def change
    add_column :purchases, :purchased_on, :date # 購入日
  end
end
