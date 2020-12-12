json.response_code @response_code
json.response_message @response_message
json.books do
  json.array! @books do |book|
    json.merge! book.json_attributes
    json.current_loans do
      json.array! book.current_loans do |loan|
        json.merge! loan.json_attributes
        json.user loan.user.json_attributes
      end
    end

    json.completed_loans do
      json.array! book.completed_loans do |loan|
        json.merge! loan.json_attributes
        json.user loan.user.json_attributes
      end
    end
  end
end
