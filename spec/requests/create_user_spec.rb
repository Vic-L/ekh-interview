# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'create_user', type: :request do
  scenario 'should return error with missing params', :show_in_doc do
    post '/api/v1/create_user', headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq 'Missing parameter amount'
    expect(response_body.response_code).to eq 'custom.errors.apipie.missing_params'
    expect(response.status).to eq 400
  end

  scenario 'should create user with specified amount', :show_in_doc do
    expect(User.count).to eq 0

    post '/api/v1/create_user', params: { amount: 9999 }.to_json, headers: ApiHelpers::DEFAULT_HEADERS

    expect(response_body.response_message).to eq I18n.t('custom.success.default')
    expect(response_body.response_code).to eq 'custom.success.default'
    expect(response.status).to eq 200

    expect(User.count).to eq 1
    expect(User.first.amount).to eq 9999
    expect(User.first.escrow).to eq 0
  end
end
