class RemoveUserAccountNo < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :account_no
  end
end
