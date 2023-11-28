# typed: strict
# frozen_string_literal: true

module AtlasEngine
  class Engine
    class << self
      sig { returns(Pathname) }
      def root; end
    end
  end
end
