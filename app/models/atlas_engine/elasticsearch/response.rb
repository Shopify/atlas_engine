# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Elasticsearch
    class Response
      extend T::Sig

      sig { returns(T.untyped) }
      attr_reader :response

      delegate :body, :status, :headers, to: :response

      sig { params(response: T.untyped).void }
      def initialize(response)
        @response = response
      end
    end
  end
end
