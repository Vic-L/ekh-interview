class SetDefaultLoansCountOnBooks < ActiveRecord::Migration[6.1]
  def change
    change_column_default :books, :loans_count, 0

    Book.where(loans_count: nil).update_all(loans_count: 0)
  end
end
