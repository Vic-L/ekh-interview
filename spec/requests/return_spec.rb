# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'return', type: :request do
  let!(:book) { create(:book) }
  let!(:user) { create(:user) }
  let!(:loan) { create(:loan, user: user, book: book) }

  scenario 'should return error with missing params', :show_in_doc do
    post '/api/v1/return', headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq 'Missing parameter user_id'
    expect(response_body.response_code).to eq 'custom.errors.apipie.missing_params'
    expect(response.status).to eq 400
  end

  scenario 'should fail if user does not exist', :show_in_doc do
    post '/api/v1/return', params: {
      user_id: user.id * 2,
      book_id: book.id,
    }.to_json,
    headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq "No active loans of this user and this book"
    expect(response_body.response_code).to eq 'custom.errors.models.loans.non_existing'
    expect(response.status).to eq 400
  end
  
  scenario 'should fail if book does not exist' do
    post '/api/v1/return', params: {
      user_id: user.id,
      book_id: book.id * 2,
    }.to_json,
    headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq "No active loans of this user and this book"
    expect(response_body.response_code).to eq 'custom.errors.models.loans.non_existing'
    expect(response.status).to eq 400
  end

  feature 'with multiple active loans on same book' do
    let!(:old_loan) { create(:loan, user: user, book: book, borrow_at: loan.borrow_at - 1.day) }

    before :each do
      expect(loan.borrow_at).to be > old_loan.borrow_at
      expect(old_loan.id).to be > loan.id
    end
    
    scenario 'should add return date to only the earliest loans with the same user and book', :show_in_doc do
      expect {
        post '/api/v1/return', params: {
          user_id: user.id,
          book_id: book.id,
        }.to_json,
        headers: ApiHelpers::DEFAULT_HEADERS
      }.to change {
        old_loan.reload.return_at
      }
    end

    scenario 'should add return date to only the earliest loans with the same user and book' do
      expect {
        post '/api/v1/return', params: {
          user_id: user.id,
          book_id: book.id,
        }.to_json,
        headers: ApiHelpers::DEFAULT_HEADERS
      }.not_to change {
        loan.reload.return_at
      }
    end
  end

  feature 'with returned loans on same book' do
    let!(:returned_loan) { create(:loan, :returned, user: user, book: book, borrow_at: loan.borrow_at - 1.day) }

    before :each do
      expect(user.loans.count).to eq 2
    end

    scenario 'should update active loan only' do
      expect {
        post '/api/v1/return', params: {
          user_id: user.id,
          book_id: book.id,
        }.to_json,
        headers: ApiHelpers::DEFAULT_HEADERS
      }.to change {
        loan.reload.return_at
      }
    end

    scenario 'should ignore returned loans' do
      expect {
        post '/api/v1/return', params: {
          user_id: user.id,
          book_id: book.id,
        }.to_json,
        headers: ApiHelpers::DEFAULT_HEADERS
      }.not_to change {
        returned_loan.reload.return_at
      }
    end
  end
  
  scenario 'should increment availability of returned book' do
    expect {
      post '/api/v1/return', params: {
        user_id: user.id,
        book_id: book.id,
      }.to_json,
      headers: ApiHelpers::DEFAULT_HEADERS
    }.to change {
      book.reload.quantity
    }.from(9)
    .to(10)
  end
  
  scenario 'should reduce user escrow by loan amount and not price constant' do
    loan.update(amount: Rails.application.config.price - 1)
    expect(loan.amount).not_to eq Rails.application.config.price

    expect {
      post '/api/v1/return', params: {
        user_id: user.id,
        book_id: book.id,
      }.to_json,
      headers: ApiHelpers::DEFAULT_HEADERS
    }.to change {
      user.reload.escrow
    }.from(Rails.application.config.price)
    .to(1)
  end
end
