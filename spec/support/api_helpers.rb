# frozen_string_literal: true

module ApiHelpers
  DEFAULT_HEADERS = {
    'CONTENT_TYPE' => 'application/json',
    'ACCEPT' => 'application/json'
  }.freeze

  def response_body
    # convert to OpenStruct to use dot notation
    # wrt https://til.hashrocket.com/posts/u8knc8jfsb-convert-nested-json-object-to-nested-openstructs
    JSON.parse(response.body, object_class: OpenStruct)
  end
end
