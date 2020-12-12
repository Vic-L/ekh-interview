Rails.application.routes.draw do
  apipie

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      # Query the account of a user and the details of the current borrowed book, The parameter is the user.
      get '/user_account', to: 'base#user_account'
      # Query the current remaining number of each book, the total number of loans, and the current loan status between the users.
      get '/books', to: 'base#books'
      # Create a user interface, the requested parameters support setting the initial amount, returning the user ID
      # Create a borrowing transaction with parameters for the user's ID and the book's ID
      # Create a return transaction with parameters for the user's ID and the book's ID
      # Query the account status of a user, the parameter is the user ID, return the current balance, and borrow the books.
      # Query the actual income of a book, the parameter is the ID and time range of the book, and return the transaction amount obtained by the book during this time.
    end
  end
end
