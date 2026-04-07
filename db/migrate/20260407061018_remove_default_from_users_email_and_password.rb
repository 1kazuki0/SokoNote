class RemoveDefaultFromUsersEmailAndPassword < ActiveRecord::Migration[7.2]
  def change
    change_column_default :users, :email, from: "", to: nil
    change_column_default :users, :encrypted_password, from: "", to: nil
  end
end
