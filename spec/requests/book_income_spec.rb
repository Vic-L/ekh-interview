# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'book_income', type: :request do
  let!(:book) { create(:book) }

  scenario 'should return error with missing params', :show_in_doc do
    get '/api/v1/book_income', headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq 'Missing parameter book_id'
    expect(response_body.response_code).to eq 'custom.errors.apipie.missing_params'
    expect(response.status).to eq 400
  end

  scenario 'should fail if book does not exist', :show_in_doc do
    get '/api/v1/book_income', params: {
      book_id: book.id * 2,
      from: (Date.today - 1.day).iso8601,
      till: (Date.today + 1.day).iso8601,
    }, headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq 'Book does not exist in our database'
    expect(response_body.response_code).to eq 'custom.errors.record_not_found'
    expect(response.status).to eq 404
  end

  feature 'with loans' do
    let!(:active_loan) { create(
        :loan,
        book: book,
        borrow_at: DateTime.now - 10.days
    ) }
    let!(:ancient_active_loan) { create(
        :loan,
        book: book,
        borrow_at: DateTime.now - 10.days
    ) }

    before :each do
      @params = {
        book_id: book.id,
        from: (Date.today - 2.weeks).iso8601,
        till: (Date.today - 1.weeks).iso8601,
      }

      [
        [DateTime.now - 15.days, nil],
        [DateTime.now - 10.days, nil],
        [DateTime.now - 15.days, DateTime.now - 10.days],
        [DateTime.now - 10.days, DateTime.now - 8.days],
        [DateTime.now - 10.days, DateTime.now - 3.days],
      ].each do |from_till|
        create(
          :loan,
          book: book,
          borrow_at: from_till[0],
          return_at: from_till[1]
        )
      end
    end

    scenario 'should return income of loans that are returned within the date range', :show_in_doc do
      get '/api/v1/book_income', params: @params, headers: ApiHelpers::DEFAULT_HEADERS

      expect(response_body.income).to eq Rails.application.config.price * 2
    end
  end
end