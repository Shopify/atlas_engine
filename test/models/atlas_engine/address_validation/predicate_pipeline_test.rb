# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressValidation
    class PredicatePipelineTest < ActiveSupport::TestCase
      test "pipeline returns predicate config for given matching strategy" do
        local_pipeline = PredicatePipeline.find("local").pipeline

        assert_equal [:country, :province, :zip, :city, :address1, :address2, :phone], local_pipeline.map(&:field).uniq
        assert subclass_of_predicate?(local_pipeline)
      end

      test "pipeline raises if invalid matching strategy is provided" do
        assert_raises FrozenRecord::RecordNotFound do
          PredicatePipeline.find("bogus").pipeline
        end
      end

      test "pipeline returns nil if full address validator class is not defined" do
        assert_nil PredicatePipeline.find("local").full_address_validator
      end

      test "pipeline returns full address validator class if defined" do
        assert_equal AtlasEngine::AddressValidation::Es::Validators::FullAddress,
          PredicatePipeline.find("es").full_address_validator
        assert_equal AtlasEngine::AddressValidation::Es::Validators::FullAddressStreet,
          PredicatePipeline.find("es_street").full_address_validator
      end

      private

      def subclass_of_predicate?(pipeline)
        pipeline.map(&:class_name).all? do |klass|
          klass < AtlasEngine::AddressValidation::Validators::Predicates::Predicate
        end
      end
    end
  end
end
