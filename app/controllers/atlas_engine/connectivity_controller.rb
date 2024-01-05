module AtlasEngine
  class ConnectivityController < ApplicationController

    def initialize
      @repository = AtlasEngine::Elasticsearch::Repository.new(
        index_base_name: "",
        index_settings: {},
        index_mappings: {},
        mapper_callable: nil
      )
    end

    def index
      @indices = @repository.indices
      @post_addresses = AtlasEngine::PostAddress.all.limit(10)
    end
  end
end
