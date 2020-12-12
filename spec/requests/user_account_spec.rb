# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'user_account', type: :request do
  let!(:user) { create(:user) }

  scenario 'should return error with missing params' do
    get '/api/v1/user_account', headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq 'Missing parameter user_id'
    expect(response_body.response_code).to eq 'custom.errors.apipie.missing_params'
    expect(response.status).to eq 400
  end

  scenario 'should return nil for a non existing user' do
    get '/api/v1/user_account', params: { user_id: user.id * 2 }, headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq I18n.t('custom.success.default')
    expect(response_body.response_code).to eq 'custom.success.default'
    expect(response.status).to eq 200

    expect(response_body.user).to eq nil
  end

  scenario 'should return empty array for current_borrowed_books if user does not have any borrowed books'
  
  scenario 'should return array for current_borrowed_books if user did borrow books'
end
