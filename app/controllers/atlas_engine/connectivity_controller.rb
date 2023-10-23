module AtlasEngine
  class ConnectivityController < ApplicationController

    def initialize
      @repository = AtlasEngine::Elasticsearch::Repository.new
    end

    def index
      @indices = @repository.indices
      @post_addresses = AtlasEngine::PostAddress.all.limit(10)
    end
  end
end
