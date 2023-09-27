module AtlasEngineTestOne
  class ConnectivityController < ApplicationController

    def initialize
      @repository = AtlasEngineTestOne::Elasticsearch::Repository.new
    end

    def index
      @indices = @repository.indices
      @post_addresses = AtlasEngineTestOne::PostAddress.all.limit(10)
    end
  end
end
