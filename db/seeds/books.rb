# frozen_string_literal: true

p 'Create books'

10.times do
  Book.create(
    title: Faker::Book.title,
    quantity: rand(5..10),
  )
end