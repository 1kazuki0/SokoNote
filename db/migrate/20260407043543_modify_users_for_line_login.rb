class ModifyUsersForLineLogin < ActiveRecord::Migration[7.2]
  def change
    # nullを許可するに変更
    change_column_null :users, :email, true
    change_column_null :users, :encrypted_password, true

    # LINEログインのため、providerとuidを追加。明示的にnullを許可
    add_column :users, :provider, :string, null: true
    add_column :users, :uid, :string, null: true

    # provider内のuidを一意にする
    add_index :users, [ "provider", "uid" ], unique: true
  end
end
