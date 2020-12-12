# frozen_string_literal: true

class Loan < ApplicationRecord
  belongs_to :user, inverse_of: :loans
  belongs_to :book, inverse_of: :loans, counter_cache: true

  validates :amount,
            :borrow_at,
            presence: true

  after_create :reduce_book_availability!
  after_create :increase_user_escrow!

  scope :active, -> { where(return_at: nil) }
  scope :past, -> { where.not(return_at: nil) }

  private

  def reduce_book_availability!
    book.subtract_available_count!
  end

  def increase_user_escrow!
    user.add_to_escrow!
  end
end
