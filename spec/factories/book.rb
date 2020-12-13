# frozen_string_literal: true

FactoryBot.define do
  factory :book do
    quantity { 10 }
    title { Faker::Book.title }

    trait :unavailable do
      quantity { 0 }
    end
  end
end
