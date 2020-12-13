json.response_code @response_code
json.response_message @response_message
json.user do
  if @user.nil?
    nil
  else
    json.merge! @user.json_attributes
    json.current_borrowed_books do
      json.array! @user.current_borrowed_books.each do |book|
        json.merge! book.json_attributes
        json.borrow_count book.borrow_count(@user)
      end
    end
  end
end
