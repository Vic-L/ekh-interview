# frozen_string_literal: true

module ApiRescues
  extend ActiveSupport::Concern

  included do
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
