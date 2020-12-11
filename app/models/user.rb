# frozen_string_literal: true

class User < ApplicationRecord
  has_many :loans, inverse_of: :user
end
