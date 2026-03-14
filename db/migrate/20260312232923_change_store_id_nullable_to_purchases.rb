class ChangeStoreIdNullableToPurchases < ActiveRecord::Migration[7.2]
  def change
    change_column_null :purchases, :store_id, true
  end
end
