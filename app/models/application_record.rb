class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def json_attributes
    attributes.dup
  end
end
