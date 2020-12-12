json.response_code @response_code
json.response_message @response_message
json.user do
  if @user.nil?
    nil
  else
    json.merge! @user.json_attributes
    json.current_borrowed_books @user.current_borrowed_books.map(&:json_attributes)
  end
end
