# frozen_string_literal: true

class Loan < ApplicationRecord
  belongs_to :user, inverse_of: :loans
  belongs_to :book, inverse_of: :loans, counter_cache: true

  validates :amount,
            :borrow_at,
            presence: true

  scope :active, -> { where(return_at: nil) }
end
