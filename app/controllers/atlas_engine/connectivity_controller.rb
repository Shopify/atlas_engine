# typed: false
# frozen_string_literal: true

module AtlasEngine
  class ConnectivityController < ApplicationController
    def initialize
      super
      @repository = AtlasEngine::Elasticsearch::Repository.new(
        index_base_name: "",
        index_settings: {},
        index_mappings: {},
        mapper_callable: nil,
      )
    end

    def index
      @indices = @repository.indices
      @post_addresses = AtlasEngine::PostAddress.limit(10)
    end
  end
end
