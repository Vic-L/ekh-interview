# frozen_string_literal: true

FactoryBot.define do
  factory :loan do
    user
    book
    amount { 100 }
    borrow_at { 24.hours.ago }

    trait :returned do
      return_at { 1.hour.ago }
    end
  end
end
