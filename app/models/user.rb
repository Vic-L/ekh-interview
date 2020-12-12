# frozen_string_literal: true

class User < ApplicationRecord
  has_many :loans, inverse_of: :user

  after_create :generate_account_no

  validates :escrow,
            :amount,
            presence: true

  def json_attributes
    custom_attributes = super
    
    custom_attributes.delete :created_at
    custom_attributes.delete :updated_at

    custom_attributes
  end

  private

  def generate_account_no
    # guarantees uniqueness since tagged to id
    self.account_no = "EKH#{self.id.to_s.rjust(7, '0')}"
  end
end
