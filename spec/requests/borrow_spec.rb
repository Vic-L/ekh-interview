# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'borrow', type: :request do
  let!(:book) { create(:book) }
  let!(:unavailable_book) { create(:book, :unavailable) }
  let!(:out_of_stock_book) { create(:book, :out_of_stock) }
  let!(:user) { create(:user) }
  let(:poor_user) { create(:user, :poor) }

  before :each do
    expect(Loan.count).to eq 0
  end

  scenario 'should return error with missing params', :show_in_doc do
    post '/api/v1/borrow', headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq 'Missing parameter user_id'
    expect(response_body.response_code).to eq 'custom.errors.apipie.missing_params'
    expect(response.status).to eq 400
  end

  scenario 'should create loan', :show_in_doc do
    expect {
      post '/api/v1/borrow', params: {
        user_id: user.id,
        book_id: book.id,
      }.to_json,
      headers: ApiHelpers::DEFAULT_HEADERS
    }.to change {
      Loan.count
    }.from(0)
    .to(1)
  end

  scenario 'should reduce availability of borrowed book' do
    expect {
      post '/api/v1/borrow', params: {
        user_id: user.id,
        book_id: book.id,
      }.to_json,
      headers: ApiHelpers::DEFAULT_HEADERS
    }.to change {
      book.reload.available_count
    }.from(10)
    .to(9)
  end

  scenario 'should fail if there is no more available books', :show_in_doc do
    post '/api/v1/borrow', params: {
      user_id: user.id,
      book_id: unavailable_book.id,
    }.to_json,
    headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq "This book is no longer available"
    expect(response_body.response_code).to eq 'custom.errors.models.books.available_count'
    expect(response.status).to eq 400
    expect(Loan.count).to eq 0
  end

  scenario 'should fail if quantity of books is 0', :show_in_doc do
    post '/api/v1/borrow', params: {
      user_id: user.id,
      book_id: out_of_stock_book.id,
    }.to_json,
    headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq "This book has been given away"
    expect(response_body.response_code).to eq 'custom.errors.models.books.quantity'
    expect(response.status).to eq 400
    expect(Loan.count).to eq 0
  end

  scenario 'should fail if user does not exist', :show_in_doc do
    post '/api/v1/borrow', params: {
      user_id: user.id * 2,
      book_id: book.id,
    }.to_json,
    headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq "Validation failed: User must exist"
    expect(response_body.response_code).to eq 'custom.errors.models.invalid'
    expect(response.status).to eq 400
    expect(Loan.count).to eq 0
  end

  scenario 'should fail if book does not exist', :show_in_doc do
    post '/api/v1/borrow', params: {
      user_id: user.id,
      book_id: book.id * 2,
    }.to_json,
    headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq "Validation failed: Book must exist"
    expect(response_body.response_code).to eq 'custom.errors.models.invalid'
    expect(response.status).to eq 400
    expect(Loan.count).to eq 0
  end

  scenario 'should add to user escrow' do
    expect {
      post '/api/v1/borrow', params: {
        user_id: user.id,
        book_id: book.id,
      }.to_json,
      headers: ApiHelpers::DEFAULT_HEADERS
    }.to change {
      user.reload.escrow
    }.from(0)
    .to(Rails.application.config.price)
  end

  scenario 'should fail if user does not have enough money', :show_in_doc do
    expect(poor_user.balance).to be < Rails.application.config.price

    post '/api/v1/borrow', params: {
      user_id: poor_user.id,
      book_id: book.id,
    }.to_json,
    headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq "This user does not have enough funds to borrow the book"
    expect(response_body.response_code).to eq 'custom.errors.models.users.insufficient_funds'
    expect(response.status).to eq 400
    expect(Loan.count).to eq 0
  end
end
