module AtlasEngine
  class ApplicationJob < ActiveJob::Base
    def argument(key)
      arguments.first&.fetch(key, nil)
    end
  end
end
