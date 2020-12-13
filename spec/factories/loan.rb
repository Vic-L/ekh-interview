# frozen_string_literal: true

FactoryBot.define do
  factory :loan do
    user
    book
    amount { Rails.application.config.price }
    borrow_at { 24.hours.ago }

    trait :returned do
      return_at { 1.hour.ago }
      after :create do |loan|
        loan.book.increment_quantity!
      end
    end
  end
end
