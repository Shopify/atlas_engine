# typed: strict
# frozen_string_literal: true

module AtlasEngine
  class AddressNumber
    extend T::Sig

    sig { returns(String) }
    attr_reader :raw

    NUMBERS = /\d+/
    NUMBERS_AND_NON_NUMBERS = %r{([A-Za-z]+|\d+\s+\d+/\d+|\d+/\d+|\d+|-)}

    sig { params(value: String).void }
    def initialize(value:)
      @raw = value
    end

    sig { returns(T.nilable(Integer)) }
    def to_i
      numbers = @raw.scan(NUMBERS).flatten
      numbers.length == 1 ? numbers[0].to_i : nil
    end

    sig { returns(T.any(Integer, Rational)) }
    def to_r
      fractions = @raw.scan(NUMBERS_AND_NON_NUMBERS).flatten
      fractions[0].to_s.split.sum(&:to_r)
    end

    sig { returns(T::Array[String]) }
    def segments
      Array(@raw.scan(NUMBERS_AND_NON_NUMBERS).flatten)
    end
  end
end
