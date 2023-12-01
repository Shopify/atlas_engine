# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Errors < AtlasEngine::CodedErrors
      error :http_issue, "There was an issue processing the request."
      error :request_issue, "There is an error with the given request."
      error :missing_parameter, "The given request is missing a required parameter."
    end
  end
end
