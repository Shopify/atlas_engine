# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Token
      extend T::Sig

      sig { returns(String) }
      attr_reader :value

      sig { returns(T.nilable(String)) }
      attr_reader :type

      sig { returns(Integer) }
      attr_accessor :position

      sig { returns(Integer) }
      attr_accessor :start_offset

      sig { returns(Integer) }
      attr_accessor :end_offset

      sig { returns(Integer) }
      attr_reader :position_length

      sig do
        params(
          value: String,
          start_offset: Integer,
          end_offset: Integer,
          position: Integer,
          type: T.nilable(String),
          position_length: Integer,
        ).void
      end
      def initialize(value:, start_offset:, end_offset:, position:, type: nil, position_length: 1)
        @value = value
        @start_offset = start_offset
        @end_offset = end_offset
        @type = type
        @position = position
        @position_length = position_length
      end

      sig { returns(T::Range[Integer]) }
      def offset_range
        @offset_range ||= start_offset...end_offset
      end

      sig { returns(String) }
      def inspect
        t = " type:#{type}" if type.present?
        pos_length = " pos_length:#{position_length}" if position_length > 1
        id = "id:#{object_id.to_s[-4..-1]}"
        details = " strt:#{start_offset} end:#{end_offset} pos:#{position}#{t}#{pos_length}"

        "<tok #{id} val:\"#{value}\"#{details}/>"
      end

      sig { returns(String) }
      def inspect_short
        id = "id:#{object_id.to_s[-4..-1]}"
        "<tok #{id} val:\"#{value}\"/>"
      end

      sig { params(other: Token).returns(T::Boolean) }
      def ==(other)
        value == other.value &&
          start_offset == other.start_offset &&
          end_offset == other.end_offset &&
          type == other.type &&
          position == other.position &&
          position_length == other.position_length
      end

      sig { params(other: Token).returns(T::Boolean) }
      def preceeds?(other)
        position == other.position - position_length
      end

      class << self
        extend T::Sig

        sig { params(field_terms: Hash).returns(T::Array[Token]) }
        def from_field_term_vector(field_terms)
          field_terms["terms"].flat_map do |term, term_info|
            term_info["tokens"].map do |token|
              new(
                value: term,
                position: token["position"],
                start_offset: token["start_offset"],
                end_offset: token["end_offset"],
              )
            end
          end.sort_by(&:position)
        end

        sig { params(token: T::Hash[String, T.untyped]).returns(Token) }
        def from_analyze(token)
          new(
            value: token["token"],
            start_offset: token["start_offset"],
            end_offset: token["end_offset"],
            type: token["type"],
            position: token["position"],
            position_length: token["positionLength"] || 1,
          )
        end
      end
    end
  end
end
