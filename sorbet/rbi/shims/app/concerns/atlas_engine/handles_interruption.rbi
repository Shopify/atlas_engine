# typed: true
# frozen_string_literal: true

module AtlasEngine
  module HandlesInterruption
    sig { params(import: CountryImport).void }
    def exit_if_interrupted!(import); end
  end
end
