# frozen_string_literal: true

module ApiRescues
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      match_data = e.message.match /^Couldn't find (\w+) with 'id'=[\S*]?/
      response_message = I18n.t('custom.errors.record_not_found', model: match_data[1].titlecase)
      render json: {
        response_code: 'custom.errors.record_not_found',
        response_message: response_message
      }, status: 404
    end

    rescue_from Apipie::ParamMissing do |e|
      render json: {
        response_code: 'custom.errors.apipie.missing_params',
        response_message: e.message
      }, status: 400
    end

    rescue_from Apipie::ParamInvalid do |e|
      render json: {
        response_code: 'custom.errors.apipie.params_invalid',
        response_message: e.message
      }, status: 400
    end
  end
end
