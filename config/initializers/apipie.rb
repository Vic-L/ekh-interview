# frozen_string_literal: true

Apipie.configure do |config|
  config.app_name = Rails.application.class.module_parent_name
  config.api_base_url['v1'] = '/api/v1'
  config.doc_base_url = '/apidoc'
  config.default_version = 'v1'
  config.translate = false
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.show_all_examples = true
end

class DateValidator < Apipie::Validator::BaseValidator
  def initialize(param_description, argument)
    super(param_description)
    @type = argument
  end

  def validate(value)
    return false if value.nil?

    !!value.try(:to_date)
  end

  def self.build(param_description, argument, options, block)
    if argument == Date
      self.new(param_description, argument)
    end
  end

  def description
    "Must be #{@type}."
  end
end
