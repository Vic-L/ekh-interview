# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    amount { 1000 }
    escrow { 0 }
  end
end
