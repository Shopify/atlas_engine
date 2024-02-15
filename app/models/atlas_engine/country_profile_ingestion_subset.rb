# typed: true
# frozen_string_literal: true

module AtlasEngine
  class CountryProfileIngestionSubset < CountryProfileSubsetBase
    sig { params(source: String).returns(T::Array[T::Class[T.anything]]) }
    def correctors(source:)
      corrector_names = attributes.dig("correctors", source) || []
      corrector_names.map(&:constantize)
    end

    sig { returns(T.nilable(String)) }
    def settings_number_of_shards
      attributes.dig("settings", "number_of_shards")
    end

    sig { returns(T.nilable(String)) }
    def settings_number_of_replicas
      attributes.dig("settings", "number_of_replicas")
    end

    sig { returns(T.nilable(String)) }
    def settings_min_zip_edge_ngram
      attributes.dig("settings", "min_zip_edge_ngram")
    end

    sig { params(source: String).returns(T::Class[AddressImporter::OpenAddress::DefaultMapper]) }
    def post_address_mapper(source)
      attributes.dig("post_address_mapper", source).constantize
    end

    sig { returns(T.nilable(String)) }
    def settings_max_zip_edge_ngram
      attributes.dig("settings", "max_zip_edge_ngram")
    end

    sig { returns(T::Class[AddressValidation::Es::DataMappers::DefaultDataMapper]) }
    def data_mapper
      attributes.dig("data_mapper").constantize
    end
  end
end
