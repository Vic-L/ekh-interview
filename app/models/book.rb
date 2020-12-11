# frozen_string_literal: true

class Book < ApplicationRecord
  has_many :loans, inverse_of: :book
end
