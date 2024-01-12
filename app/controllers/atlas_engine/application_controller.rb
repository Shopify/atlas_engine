# typed: false
# frozen_string_literal: true

module AtlasEngine
  # rubocop:disable Sorbet/ConstantsFromStrings
  class ApplicationController < AtlasEngine.parent_controller.constantize
    # T.unsafe(self).include(AtlasEngine.parent_controller.constantize)
  end
  # rubocop:enable Sorbet/ConstantsFromStrings
end
