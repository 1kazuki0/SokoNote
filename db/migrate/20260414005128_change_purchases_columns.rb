class ChangePurchasesColumns < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :purchases, :stores                                                     # 外部制約を一度解除する
    add_foreign_key :purchases, :stores, on_delete: :nullify                                   # 親のstoreレコードが消されても、purchases.store_idはnil
    change_column :purchases, :content_quantity, :decimal, precision: 8, scale: 2, null: false # 内容量のinteger(整数)からdecimal(小数)に変更
    change_column_default :purchases, :pack_quantity, from: nil, to: 1                         # パック数のデフォルト値を1に変更
    change_column_null :purchases, :unit_price, false                                          # 計算後の単価のnull禁止
    change_column_null :purchases, :purchased_on, false                                        # 購入日のnull禁止
    change_column_default :purchases, :purchased_on, from: nil, to: -> { "CURRENT_DATE" }      # 購入日のデフォルト値を今日
  end
end
