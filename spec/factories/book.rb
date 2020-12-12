# frozen_string_literal: true

FactoryBot.define do
  factory :book do
    quantity { 10 }
    available_count { 10 }
    title { Faker::Book.title }
  end
end
