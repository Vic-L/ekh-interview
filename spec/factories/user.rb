# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    amount { 1000 }
    escrow { 0 }

    trait :with_books do
      after :create do |user|
        create_list(:loan, 2, :returned, user: user)
        create_list(:loan, 2, user: user)
      end
    end

    trait :with_same_books do
      after :create do |user|
        book = create(:book)
        create_list(:loan, 2, user: user, book: book)
      end
    end

    trait :poor do
      escrow { 999 }
    end
  end
end
