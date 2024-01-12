# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class PredicatePipeline < FrozenRecord::Base
      extend T::Sig

      VALIDATION_PIPELINES_ROOT = T.let(File.join(AtlasEngine::Engine.root, "db/data/validation_pipelines"), String)

      module Backend
        extend FrozenRecord::Backends::Yaml

        class << self
          extend T::Sig

          sig { params(file_path: String).returns(T.untyped) }
          def load(file_path)
            # FrozenRecord's default is to operate on a single YAML file containing all the records.
            # A custom backend like ours, that uses separate files, must load all of them and return an array.
            Dir[File.join(PredicatePipeline.pipeline_path, "*.yml")].map do |validation_pipeline|
              super(validation_pipeline)
            end
          end
        end
      end

      class << self
        extend T::Sig

        sig { returns(String) }
        def pipeline_path
          @pipeline_path ||= T.let(VALIDATION_PIPELINES_ROOT, T.nilable(String))
        end

        sig { params(pipeline_path: String).void }
        attr_writer :pipeline_path
      end

      self.base_path = VALIDATION_PIPELINES_ROOT
      self.backend = Backend

      sig { returns(T::Array[PredicateConfig]) }
      def pipeline
        attributes.dig("pipeline").map do |config|
          PredicateConfig.new(
            class_name: config["class"].constantize,
            field: config["field"].to_sym,
          )
        end
      end

      sig { returns(T.nilable(T::Class[FullAddressValidatorBase])) }
      def full_address_validator
        attributes.dig("full_address_validator")&.constantize
      end

      class PredicateConfig
        extend T::Sig

        sig { returns(Symbol) }
        attr_reader :field

        sig { returns(T::Class[Validators::Predicates::Predicate]) }
        attr_reader :class_name

        sig do
          params(
            class_name: T::Class[Validators::Predicates::Predicate],
            field: Symbol,
          ).void
        end
        def initialize(class_name:, field:)
          @field = field
          @class_name = class_name
        end
      end
    end
  end
end
