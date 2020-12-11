# frozen_string_literal: true

class Loan < ApplicationRecord
  belongs_to :user, inverse_of: :loans
  belongs_to :book, inverse_of: :loans
end
