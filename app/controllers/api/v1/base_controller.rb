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

      api :GET, '/books', "Query the current remaining number of each book, the total number of loans, and the current loan status between the users."
      description "Query the current remaining number of each book, the total number of loans, and the current loan status between the users."
      header 'Content-Type', 'application/json'
      header 'Accept', 'application/json'
      def books
        @books = Book.includes(:loans).includes(loans: :user)
      end

      api :POST, '/create_user', "Create a user interface, the requested parameters support setting the initial amount, returning the user ID"
      description "Create a user interface, the requested parameters support setting the initial amount, returning the user ID"
      header 'Content-Type', 'application/json'
      header 'Accept', 'application/json'
      param :amount, Integer, required: true, desc: "Provide value in cents"
      def create_user
        @user = User.create(amount: user_params[:amount], escrow: 0)
      end

      private

      def user_params
        params.permit(:user_id, :amount)
      end

      def add_default_response_keys
        @response_code ||= 'custom.success.default'
        @response_message ||= I18n.t('custom.success.default')
      end
    end
  end
end
