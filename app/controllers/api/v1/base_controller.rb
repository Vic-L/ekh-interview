# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include ApiRescues

      before_action :add_default_response_keys

      api :GET, '/user_account', "Query the account of a user and the details of the current borrowed book, The parameter is the user."
      description "Query the account of a user and the details of the current borrowed book, The parameter is the user."
      header 'Content-Type', 'application/json'
      header 'Accept', 'application/json'
      param :user_id, [Integer, String], required: true
      def user_account
        begin
          @user = User.includes(:loans).includes(loans: :book).find(user_params[:user_id])
        rescue ActiveRecord::RecordNotFound => e
          # puts e.message # for logging

          response_code = 'custom.errors.record_not_found'
          render json: {
            response_code: response_code,
            response_message: I18n.t(response_code, model: 'User'),
          }, status: 404
        end
      end

      private

      def user_params
        params.permit(:user_id)
      end

      def add_default_response_keys
        @response_code ||= 'custom.success.default'
        @response_message ||= I18n.t('custom.success.default')
      end
    end
  end
end
