class CreateLoans < ActiveRecord::Migration[6.1]
  def change
    create_table :loans do |t|
      t.references :user, index: true
      t.references :book, index: true
      t.datetime :borrow_at, index: true
      t.datetime :return_at, index: true
      t.integer :amount, limit: 2

      t.timestamps
    end
  end
end
