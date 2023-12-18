# typed: true
# frozen_string_literal: true

module AtlasEngine
  class Street
    extend T::Sig

    attr_reader :street

    sig { params(street: String).void }
    def initialize(street:)
      @street = street
    end

    sig { returns(T.nilable(String)) }
    def name
      parsing[:name]
    end

    sig { returns(String) }
    def with_stripped_name
      return street if name.blank?

      street.sub(name, T.must(name).gsub(/\s+/, ""))
    end

    private

    sig { returns(T::Hash[Symbol, String]) }
    def parsing
      @parsing ||= AtlasEngine::ValidationTranscriber::StreetParser.new.parse(street: street)
    end
  end
end
