# typed: true
# frozen_string_literal: true

require "rails/all"

module AtlasEngine
  class Engine < ::Rails::Engine
    isolate_namespace AtlasEngine
  end
end
