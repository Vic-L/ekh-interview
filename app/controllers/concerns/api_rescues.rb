# frozen_string_literal: true

module ApiRescues
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      match_data = e.message.match /^Couldn't find (\w+) with 'id'=[\S*]?/
      response_code = 'custom.errors.record_not_found'
      response_message = I18n.t(response_code, model: match_data[1].titlecase)
      render json: {
        response_code: response_code,
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

    rescue_from CustomException do |e|
      render json: {
        response_code: e.code,
        response_message: e.message
      }, status: 400
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      response_code = 'custom.errors.models.invalid'
      render json: {
        response_code: response_code,
        response_message: e.message
      }, status: 400
    end
  end
end
