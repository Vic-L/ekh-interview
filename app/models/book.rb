# frozen_string_literal: true

class Book < ApplicationRecord
  has_many :loans, inverse_of: :book
  has_many :current_loans, -> { active }, class_name: 'Loan'
  has_many :completed_loans, -> { past }, class_name: 'Loan'

  def subtract_quantity!
    self.lock!

    raise CustomException, "custom.errors.models.books.quantity" if quantity.zero?

    self.update!(quantity: self.quantity - 1)
  end

  def increment_quantity!
    self.lock!

    self.update!(quantity: self.quantity + 1)
  end

  def income from:, till:
    completed_loans.where("return_at >= ? AND return_at <= ?", from, till).sum(:amount)
  end

  def borrow_count user
    user.current_loans.pluck(:book_id).count(self.id)
  end
end
