# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Errors < AtlasEngine::CodedErrors
      HTTP_ISSUE = T.let(error(:http_issue, "There was an issue processing the request."), CodedError)
      REQUEST_ISSUE = T.let(error(:request_issue, "There is an error with the given request."), CodedError)
      MISSING_PARAMETER =
        T.let(error(:missing_parameter, "The given request is missing a required parameter."), CodedError)
    end
  end
end
