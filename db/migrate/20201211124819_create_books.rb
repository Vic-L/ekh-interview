class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.integer :quantity, limit: 1
      t.integer :available_count, limit: 1
      t.integer :loans_count

      t.timestamps
    end
  end
end
