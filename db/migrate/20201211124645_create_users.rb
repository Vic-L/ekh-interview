class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.integer :amount, limit: 2
      t.integer :escrow, limit: 2

      t.timestamps
    end
  end
end
