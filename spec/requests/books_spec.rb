# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'books', type: :request do
  feature 'with no books' do
    scenario 'should return empty array if there are no books', :show_in_doc do
      get '/api/v1/books', headers: ApiHelpers::DEFAULT_HEADERS

      expect(response_body.response_message).to eq I18n.t('custom.success.default')
      expect(response_body.response_code).to eq 'custom.success.default'
      expect(response.status).to eq 200

      expect(response_body.books).to eq []
    end
  end

  feature 'with books' do
    let!(:book1) { create(:book) }
    let!(:book2) { create(:book) }
    let!(:user) { create(:user) }
    let!(:loan) { create(:loan, book: book1, user: user) }
    let!(:returned_loan) { create(:loan, :returned, book: book1, user: user) }

    scenario 'should return books with related user and their old and current loans', :show_in_doc do
      get '/api/v1/books', headers: ApiHelpers::DEFAULT_HEADERS

      expect(response_body.response_message).to eq I18n.t('custom.success.default')
      expect(response_body.response_code).to eq 'custom.success.default'
      expect(response.status).to eq 200

      expect(response_body.books.length).to eq 2

      expect(response_body.books.first.id).to eq book1.id
      book = response_body.books.first
      expect(book.loans_count).to eq 2
      expect(book.quantity).to eq 9

      expect(book.current_loans.count).to eq 1
      current_loan = book.current_loans.first
      expect(current_loan.id).to eq loan.id
      expect(current_loan.book_id).to eq book1.id
      expect(current_loan.user.id).to eq user.id

      expect(book.completed_loans.count).to eq 1
      past_loan = book.completed_loans.first
      expect(past_loan.id).to eq returned_loan.id
      expect(past_loan.book_id).to eq book1.id
      expect(past_loan.user.id).to eq user.id
    end
  end
end
