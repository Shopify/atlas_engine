# typed: false
# frozen_string_literal: true

module AtlasEngine
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
