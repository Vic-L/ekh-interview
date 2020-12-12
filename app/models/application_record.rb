class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def json_attributes
    custom_attributes = attributes.dup
    
    custom_attributes.delete 'created_at'
    custom_attributes.delete 'updated_at'

    custom_attributes
  end
end
