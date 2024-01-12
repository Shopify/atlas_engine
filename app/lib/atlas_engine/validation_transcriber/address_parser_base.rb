# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    class AddressParserBase
      extend T::Sig
      extend T::Helpers
      include Formatter

      AddressComponents = T.type_alias { T::Hash[Symbol, String] }

      # Note that parse() returns an array of possible interpretations.
      # This is because some address lines are ambiguous, and can be interpreted multiple ways.
      # Example 1:  "123 County Road 45"
      #  - {building_num: "123", street: "County Road", unit_num: "45"}
      #  - {building_num: "123", street: "County Road 45"}
      # Example 2:  "123 E 45"
      #  - {building_num: "123", street: "E", unit_num: "45"} # 123 E Street Apt 45
      #  - {building_num: "123", street: "E 45"} # 123 East 45th Street

      # Parts that we slot into address format regular expressions

      BUILDING_NAME = "(?<building_name>[\\w ]+)"
      BUILDING_NUM =
        "(?<building_num>("\
          '([[:digit:]]+\s)?([[:digit:]]+/[[:digit:]]+)|'\
          '[[:digit:]][[:alpha:][:digit:]/\-]*|'\
          '[[:alpha:]][[:digit:]][[:alpha:][:digit:]/\-]*'\
          "))"
      NUMERIC_ONLY_BUILDING_NUM =
        "(?<building_num>("\
          '([[:digit:]]+\s+)?[[:digit:]][[:digit:]/]*[[:digit:]]|'\
          "[[:digit:]]+"\
          "))"
      NON_NUMERIC_STREET = "(?<street>[^[:digit:]/ -].*)"
      STREET = "(?<street>.+)"
      STREET_NO_COMMAS = "(?<street>[^,]+)"
      UNIT_TYPE = '(?<unit_type>[[:alpha:]]+\.?)'
      UNIT_NUM = '(?<unit_num>[[:alpha:][:digit:]/\-]+)'
      UNIT_NUM_NO_HYPHEN = "(?<unit_num>[[:alpha:][:digit:]/]+)"
      PO_BOX = %r{(?:^|\s|/)(?:p(?:ost)?\.?\s*o(?:ffice)?\.?\s*box|box|postal\s*box)\s+(\d+)(?:$|\s)}i

      sig do
        params(address: AddressValidation::AbstractAddress, preprocessor: T.nilable(AddressParserPreprocessor)).void
      end
      def initialize(address:, preprocessor: nil)
        raise ArgumentError, "country_code cannot be blank in address" if address.country_code.blank?

        @constants = T.let(
          AtlasEngine::ValidationTranscriber::Constants.instance,
          AtlasEngine::ValidationTranscriber::Constants,
        )
        @country_regex_formats = T.let(nil, T.nilable(T::Array[Regexp]))
        @address = T.let(address, AddressValidation::TAddress)

        @preprocessor = T.let(
          preprocessor || AddressParserPreprocessor.new(address: @address),
          T.nilable(ValidationTranscriber::AddressParserPreprocessor),
        )
      end

      sig { returns(T::Array[AddressComponents]) }
      def parse
        candidates = []

        address_lines = @preprocessor&.generate_combinations

        return candidates if address_lines&.empty?

        address_lines&.each do |address_line|
          address_line, po_box = extract_po_box(address_line)

          country_regex_formats.each do |format|
            m = format.match(address_line)
            next if m.nil?

            captures = m.named_captures.symbolize_keys

            next if ridiculous?(captures, @address)

            captures = captures.compact_blank.transform_values! do |value|
              strip_trailing_punctuation(value)
            end
            captures[:po_box] = po_box if po_box

            candidates << captures
          end

          if po_box && candidates.empty?
            candidates << { po_box: po_box }
          end
        end

        candidates.uniq
      end

      private

      sig { returns(T::Array[Regexp]) }
      def country_regex_formats
        []
      end

      sig { params(address_line: String).returns(T::Array[T.nilable(String)]) }
      def extract_po_box(address_line)
        po_box_match = address_line.match(PO_BOX)

        if po_box_match
          po_box = po_box_match[1]
          address_line = address_line.gsub(PO_BOX, "").strip
        else
          po_box = nil
        end

        [address_line, po_box]
      end

      # Return true if something's obviously wrong with this regex match
      sig do
        params(
          captures: T::Hash[Symbol, T.nilable(String)],
          address: AddressValidation::AbstractAddress,
        ).returns(T::Boolean)
      end
      def ridiculous?(captures, address)
        building_num = captures[:building_num]&.downcase
        street = captures[:street]&.downcase
        unit_num = captures[:unit_num]&.downcase
        unit_type = captures[:unit_type]&.downcase
        num_street_space = captures[:num_street_space] # space between building_num and street, if present

        if street.present?
          return true unless address.address1&.upcase&.include?(street.upcase) ||
            address.address2&.upcase&.include?(street.upcase)
        end

        return true if [building_num, street].any? do |token|
          po_box?(token) || street_suffix?(token)
        end

        return false if unit_num.present? && secondary_unit_designator?(unit_type)

        return true if [unit_num, unit_type].any? do |token|
          po_box?(token) || street_suffix?(token)
        end

        street_tokens_ridiculous?(
          street: T.must(street),
          unit_type: unit_type,
          unit_num: unit_num,
          num_street_space: num_street_space,
        )
      end

      sig { params(token: T.nilable(String)).returns(T::Boolean) }
      def po_box?(token)
        return false if token.blank?

        token.match?(/^\s*p\.?\s*o\.?\s*box\s*$/) ||
          token.match?(/^\s*post\s*office\s*box\s*$/)
      end

      sig { params(token: T.nilable(String)).returns(T::Boolean) }
      def secondary_unit_designator?(token)
        @constants.known?(:secondary_unit_designators, token)
      end

      sig { params(token: T.nilable(String)).returns(T::Boolean) }
      def street_suffix?(token)
        @constants.known?(:street_suffixes, token)
      end

      sig do
        params(
          street: T.nilable(String),
          unit_type: T.nilable(String),
          unit_num: T.nilable(String),
          num_street_space: T.nilable(String),
        )
          .returns(T::Boolean)
      end
      def street_tokens_ridiculous?(street:, unit_type:, unit_num:, num_street_space:)
        return false if street.blank?

        street_tokens = street.to_s.split(" ")
        return true if secondary_unit_designator?(street_tokens[-1]) && !street_suffix?(street_tokens[-1])
        return true if secondary_unit_designator?(street_tokens[-2]) && !street_suffix?(street_tokens[-1])
        return true if street_tokens.last&.start_with?("#")
        return true if unit_type.present? && !secondary_unit_designator?(unit_type)

        ["st", "nd", "rd", "th", "er", "eme"].each do |suffix|
          return true if unit_num&.end_with?(suffix)
          return true if num_street_space.nil? && street.split(" ").first == suffix
        end

        false
      end
    end
  end
end
