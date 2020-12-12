# frozen_string_literal: true

class CustomException < StandardError
  attr_reader :code
  
  def initialize code
    @code = code
    super(I18n.t(code))
  end
end
