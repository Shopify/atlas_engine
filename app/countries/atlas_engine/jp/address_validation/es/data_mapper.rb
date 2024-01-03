# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Jp
    module AddressValidation
      module Es
        class DataMapper < AtlasEngine::AddressValidation::Es::DataMappers::DefaultDataMapper
          sig do
            returns(T::Hash[Symbol, T.untyped])
          end
          def map_data
            if T.must(locale_language_code.casecmp("en")).zero?
              super.merge(en_modifications)
            else
              super.merge(ja_modifications)
            end
          end

          private

          sig { returns(T::Hash[T.untyped, T.untyped]) }
          def en_modifications
            {
              region3: mapped_region_3,
              city_aliases: city_aliases(mapped_cities),
              street: format_en_street(
                components: [
                  mapped_region_3.gsub("Others", ""),
                  post_address[:region4],
                ],
              ),
            }
          end

          sig { returns(T::Hash[T.untyped, T.untyped]) }
          def ja_modifications
            {
              region3: mapped_region_3,
              city_aliases: city_aliases(mapped_cities),
              street: "#{post_address[:region4]}#{mapped_region_3.gsub("その他", "")}",
            }
          end

          sig { returns(String) }
          def mapped_region_3
            post_address[:city].first
          end

          sig { returns(T::Array[String]) }
          def mapped_cities
            [post_address[:region3]]
          end

          sig { params(components: T::Array[T.nilable(String)]).returns(T.nilable(String)) }
          def format_en_street(components:)
            Worldwide.lists.format(components.compact.reject(&:empty?), join: :narrow)
          end
        end
      end
    end
  end
end
