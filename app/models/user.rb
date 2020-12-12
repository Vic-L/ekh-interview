# frozen_string_literal: true

class User < ApplicationRecord
  has_many :loans, inverse_of: :user

  validates :escrow,
            :amount,
            presence: true

  def json_attributes
    custom_attributes = super

    custom_attributes['account_no'] = account_no

    custom_attributes
  end

  def current_loans
    loans.includes(:book).active
  end

  def current_borrowed_books
    Book.where(id: current_loans.pluck(:book_id).uniq)
  end

  def account_no
    "EKH#{id.to_s.rjust(7, '0')}"
  end

  def balance
    amount - escrow
  end

  def add_to_escrow!
    self.lock!

    raise CustomException, "custom.errors.models.users.insufficient_funds" if balance < Rails.application.config.price

    self.update!(escrow: self.escrow + Rails.application.config.price)
  end

  def return! loan
    self.lock!

    self.update!(
      escrow: self.escrow - loan.amount,
      amount: self.amount - loan.amount,
    )
  end
end
