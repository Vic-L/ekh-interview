# frozen_string_literal: true

class Book < ApplicationRecord
  has_many :loans, inverse_of: :book

  def json_attributes
    custom_attributes = super
    
    custom_attributes.delete 'created_at'
    custom_attributes.delete 'updated_at'

    custom_attributes
  end
end
