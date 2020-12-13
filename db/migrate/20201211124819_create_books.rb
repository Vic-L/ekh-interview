class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.string :title
      t.integer :quantity, limit: 1
      t.integer :loans_count, default: 0

      t.timestamps
    end
  end
end
