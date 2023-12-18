# typed: true
# frozen_string_literal: true

module AtlasEngine
  class FieldDecompounder
    extend T::Sig

    attr_reader :field, :value, :country_profile

    sig { params(field: Symbol, value: T.nilable(String), country_profile: CountryProfile).void }
    def initialize(field:, value:, country_profile:)
      @field = field
      @value = value
      @country_profile = country_profile
    end

    sig { returns(T.nilable(String)) }
    def call
      country_profile.decompounding_patterns(field)&.each do |pattern|
        transliterated_street = ActiveSupport::Inflector.transliterate(value.to_s)
        if (match = transliterated_street.match(expanded_pattern(pattern)))
          return (match[:pre] + match[:name] + " " + match[:suffix] + match[:post]).strip
        end
      end

      value
    end

    private

    sig { params(pattern: String).returns(Regexp) }
    def expanded_pattern(pattern)
      /(?<pre>.*\b)#{pattern}(?<post>.*)/i
    end
  end
end
