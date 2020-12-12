# frozen_string_literal: true

class Book < ApplicationRecord
  has_many :loans, inverse_of: :book

  def current_loans
    loans.active
  end

  def completed_loans
    loans.past
  end

  def subtract_available_count!

    raise CustomException, "custom.errors.models.books.quantity" if quantity.zero?
    raise CustomException, "custom.errors.models.books.available_count" if available_count.zero?

    self.update!(available_count: self.available_count - 1)
  end

  def increment_available_count!
    self.update!(available_count: self.available_count + 1)
  end
end
