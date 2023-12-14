# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    class AddressParserPreprocessor
      include Formatter
      include AddressParsingHelper
      extend T::Sig

      sig do
        params(
          address: AddressValidation::TAddress,
        ).void
      end
      def initialize(address:)
        raise ArgumentError, "country_code cannot be blank in address" if address.country_code.blank?

        @country = T.let(Worldwide.region(code: address.country_code), Worldwide::Region)
        @address = address
        @combinations = T.let(Set.new, T::Set[T.nilable(String)])
      end

      sig { returns(T::Array[String]) }
      def generate_combinations
        @combinations << @address.address1
        @combinations << @address.address2
        @combinations << combined_address_lines
        @combinations << address_1_stripped_of_known_components_excluding_zip
        @combinations << address_1_stripped_of_known_components
        @combinations << address_1_sliced_on_street

        @combinations.compact_blank.uniq
      end

      private

      sig { returns(String) }
      def combined_address_lines
        [@address.address1, @address.address2].compact_blank.join(" ")
      end

      sig { returns(T.nilable(String)) }
      def address_1_stripped_of_known_components_excluding_zip
        @address_1_stripped_of_known_components_excluding_zip ||= T.let(
          begin
            # rubocop:disable Lint/NoReturnInBeginEndBlocks
            return if @address.address1.blank? || @address.nil?
            # rubocop:enable Lint/NoReturnInBeginEndBlocks

            components_to_strip = [
              @address.address2,
              @address.city,
              possible_province_words,
              possible_country_words,
            ]

            address_line = T.must(@address.address1)
            components_to_strip.flatten.compact_blank.each do |address_component|
              address_line = strip_word(address_line, address_component)
            end

            address_line
          end,
          T.nilable(String),
        )
      end

      sig { returns(T.nilable(String)) }
      def address_1_stripped_of_known_components
        modified_address1 = address_1_stripped_of_known_components_excluding_zip
        possible_zip = possible_zip_word
        return if modified_address1.blank? || possible_zip.blank?

        strip_word(modified_address1, possible_zip)
      end

      sig { returns(T.nilable(String)) }
      def address_1_sliced_on_street
        return unless @country.legacy_code == "US" && @address.address1.present?

        address_line_tokens = T.must(@address.address1).split(" ")
        street_suffix_index = address_line_tokens.rindex do |token|
          street_suffix?(token)
        end

        return unless street_suffix_index

        index_to_slice = if directional?(address_line_tokens[street_suffix_index + 1])
          street_suffix_index + 1
        else
          street_suffix_index
        end

        slice_at_index(address_line_tokens, index_to_slice)
      end

      sig { returns(T::Array[String]) }
      def possible_province_words
        province_code = @address.province_code
        return [] if province_code.blank?

        zone = @country.zone(code: province_code)
        return [] unless zone.province?

        [
          province_code,
          zone.code_alternates,
          zone.name_alternates,
          zone.full_name,
        ].flatten.compact
      end

      sig { returns(T::Array[String]) }
      def possible_country_words
        [@country.legacy_code.to_s, @country.full_name, @country.name_alternates].flatten.compact
      end

      sig { returns(T.nilable(String)) }
      def possible_zip_word
        return if @address.zip.blank?

        @address.zip if @country.valid_zip?(@address.zip)
      end

      sig { params(tokens: T::Array[String], index: Integer).returns(String) }
      def slice_at_index(tokens, index)
        T.must(tokens[..index]).join(" ")
      end
    end
  end
end
