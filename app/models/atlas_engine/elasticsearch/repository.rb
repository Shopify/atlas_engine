# frozen_string_literal: true

module AtlasEngine
  module Elasticsearch
    class Repository

      def initialize
        @default_client = AtlasEngine::Elasticsearch::Client.new
      end

      def indices
        response = @default_client.get("/_cat/indices?format=json")
        if response.status == 200
          response.body
        else
          []
        end
      end
    end
  end
end
