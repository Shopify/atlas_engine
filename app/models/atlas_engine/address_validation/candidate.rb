# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Candidate
      extend T::Sig
      attr_reader :id, :index

      sig { params(id: String, source: Hash, index: T.nilable(String)).void }
      def initialize(id:, source:, index: nil)
        components_hash = Hash.new { |hash, key| hash[key] = Component.new(key, nil) }

        @components = source.each_with_object(components_hash) do |(key, value), hash|
          hash[key.to_sym] = Component.new(key.to_sym, value)
        end

        @id = id
        @components[:id] = Component.new(:id, id)
        @index = index
      end

      sig { params(name: Symbol).returns(T.nilable(Component)) }
      def component(name)
        @components[name]
      end

      sig { params(names: Symbol).returns(T::Hash[Symbol, Component]) }
      def components(*names)
        return @components.reject { |_, component| component.value.nil? } if names.empty?

        names.index_with do |name|
          component(name)
        end
      end

      sig { returns(String) }
      def serialize
        components(:locale, :province_code, :region2, :region3, :region4, :zip, :city, :suburb, :street)
          .values.map(&:serialize).join(",")
      end

      sig { returns(T::Boolean) }
      def describes_po_box?
        component(:street)&.value&.casecmp("po box") == 0
      end

      sig { returns(T::Boolean) }
      def describes_general_delivery?
        component(:street)&.value&.casecmp("general delivery") == 0
      end

      class << self
        extend T::Sig

        sig { params(hit: Hash).returns(Candidate) }
        def from(hit)
          id = hit.dig("_id")
          source = hit.dig("_source")
          source["city"] = source["city_aliases"].map(&:values).flatten if source["city_aliases"]
          index = hit.dig("_index")
          new(id: id, source: source, index: index)
        end
      end

      class Component
        extend T::Sig

        attr_reader :name
        attr_writer :sequences
        attr_accessor :value

        sig do
          params(
            name: Symbol,
            value: T.nilable(T.any(String, Integer, Float, T::Boolean, Array, Hash, BigDecimal)),
          ).void
        end
        def initialize(name, value)
          @name = name
          @value = value
        end

        def first_value
          values.first
        end

        sig { returns(T::Array[AtlasEngine::AddressValidation::Token::Sequence]) }
        def sequences
          @sequences ||= values.map { |val| AtlasEngine::AddressValidation::Token::Sequence.from_string(val) }
        end

        sig { returns(String) }
        def serialize
          if value.is_a?(Array)
            "[#{value.map(&:to_s).join(",")}]"
          else
            value.to_s
          end
        end

        sig { returns(T::Array[String]) }
        def values
          Array(value)
        end
      end
    end
  end
end
