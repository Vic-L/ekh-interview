# frozen_string_literal: true

FactoryBot.define do
  factory :book do
    quantity { 10 }
    available_count { 10 }
    title { Faker::Book.title }

    trait :unavailable do
      available_count { 0 }
    end

    trait :out_of_stock do
      quantity { 0 }
    end
  end
end
