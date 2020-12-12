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
        @user = User.includes(:loans).includes(loans: :book).find(user_params[:user_id])
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

      api :POST, '/borrow', "Create a borrowing transaction with parameters for the user's ID and the book's ID"
      description "Create a borrowing transaction with parameters for the user's ID and the book's ID"
      header 'Content-Type', 'application/json'
      header 'Accept', 'application/json'
      param :user_id, [Integer, String], required: true
      param :book_id, [Integer, String], required: true
      def borrow
        @loan = Loan.create!(
          user_id: transaction_params[:user_id],
          book_id: transaction_params[:book_id],
          amount: Rails.application.config.price,
          borrow_at: DateTime.now
        )
      end

      api :POST, '/return', "Create a return transaction with parameters for the user's ID and the book's ID"
      description "Create a return transaction with parameters for the user's ID and the book's ID"
      header 'Content-Type', 'application/json'
      header 'Accept', 'application/json'
      param :user_id, [Integer, String], required: true
      param :book_id, [Integer, String], required: true
      def return
        @loan = Loan.active.where(
          user_id: transaction_params[:user_id],
          book_id: transaction_params[:book_id],
        ).order(:borrow_at).first
        
        raise CustomException, "custom.errors.models.loans.non_existing" if @loan.nil?

        @loan.return!
      end

      api :GET, '/book_income', "Query the actual income of a book, the parameter is the ID and time range of the book, and return the transaction amount obtained by the book during this time."
      description "Query the actual income of a book, the parameter is the ID and time range of the book, and return the transaction amount obtained by the book during this time."
      header 'Content-Type', 'application/json'
      header 'Accept', 'application/json'
      param :book_id, [Integer, String], required: true
      param :from, Date, required: true
      param :till, Date, required: true
      def book_income
        book = Book.includes(:loans).find(book_params[:book_id])
        @income = book.income(
          from: book_params[:from].to_date.beginning_of_day,
          till: book_params[:till].to_date.end_of_day
        )
      end

      private

      def user_params
        params.permit(:user_id, :amount)
      end

      def transaction_params
        params.permit(:user_id, :book_id)
      end

      def book_params
        params.permit(:book_id, :from, :till)
      end

      def add_default_response_keys
        @response_code ||= 'custom.success.default'
        @response_message ||= I18n.t('custom.success.default')
      end
    end
  end
end
