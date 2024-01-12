# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class CountryProfileTest < ActiveSupport::TestCase
    class SampleChildProfile < AtlasEngine::CountryProfile; end

    def setup
      @default_paths = CountryProfile.default_paths.dup
      @country_paths = CountryProfile.country_paths.dup
    end

    def teardown
      CountryProfile.reset!
      CountryProfile.default_paths = @default_paths
      CountryProfile.country_paths = @country_paths
    end

    test ".for raises a CountryNotFoundError for blank codes" do
      assert_raises(CountryProfile::CountryNotFoundError) { CountryProfile.for("") }
    end

    test ".for returns the default profile for the DEFAULT country code" do
      assert_equal CountryProfile::DEFAULT_PROFILE, CountryProfile.for(CountryProfile::DEFAULT_PROFILE).id
    end

    test ".for raises a CountryNotFoundError for non-country codes" do
      assert_raises(CountryProfile::CountryNotFoundError) { CountryProfile.for("ZZ") }
    end

    test ".for returns a CountryProfile for a valid country code" do
      assert_equal "US", CountryProfile.for("US").id
    end

    test ".for returns a CountryProfile for a valid country code in lowercase" do
      assert_equal "US", CountryProfile.for("us").id
    end

    test ".for returns the default profile if there is no profile yaml for a valid country code" do
      CountryProfile.expects(:find).raises(FrozenRecord::RecordNotFound)
      assert_equal "US", CountryProfile.for("US").id
    end

    test ".for returns the default profile if there is no profile yaml for a valid lowercase country code" do
      CountryProfile.expects(:find).raises(FrozenRecord::RecordNotFound)
      assert_equal "US", CountryProfile.for("us").id
    end

    test ".for returns a localized CountryProfile for a valid country code and locale" do
      CountryProfile.expects(:find).with("CH_DE").returns(CountryProfile.new(id: "CH_DE"))
      assert_equal "CH_DE", CountryProfile.for("CH", "DE").id
    end

    test ".for returns a CountryProfile if there is no profile yaml for the locale" do
      CountryProfile.expects(:find).with("CH_DE").raises(FrozenRecord::RecordNotFound)
      CountryProfile.expects(:find).with("CH").returns(CountryProfile.new(id: "CH"))
      assert_equal "CH", CountryProfile.for("CH", "DE").id
    end

    test ".for returns the default profile if there is no profile yaml for the country and locale" do
      CountryProfile.expects(:find).with("CH_DE").raises(FrozenRecord::RecordNotFound)
      CountryProfile.expects(:find).with("CH").raises(FrozenRecord::RecordNotFound)
      assert_equal "CH", CountryProfile.for("CH", "DE").id
    end

    test "default_attributes loads correctly from default.yml" do
      expected = YAML.load_file(CountryProfile.default_paths.first)
      assert_equal expected, CountryProfile.default_attributes
    end

    test "Nested values not defined in country profile are set using defaults if provided" do
      profile = CountryProfile.new({
        "id" => "XX",
        "validation" => {
          "key" => "some_value",
        },
      })

      assert_equal("some_value", profile.validation.key)
      assert_equal(false, profile.validation.enabled)
      assert_equal("local", profile.validation.default_matching_strategy)
      assert_equal(["city_aliases"], profile.validation.city_fields)
      assert_equal([], profile.validation.normalized_components)
      assert_equal({}, profile.validation.exclusions)
      assert_equal({}, profile.validation.partial_postal_code_range_for_length)
      assert_equal("AtlasEngine::AddressValidation::Es::DefaultQueryBuilder", profile.validation.query_builder)

      assert_equal(ValidationTranscriber::AddressParserBase, profile.validation.address_parser)
    end

    test ".partial_zip_allowed_countries returns a list of profiles with partial_zip_allowed?: true" do
      assert_equal Set.new(["IE"]), CountryProfile.partial_zip_allowed_countries
    end

    test "#correctors returns an array of corrector class names for a given data source" do
      country_profile = CountryProfile.for("IT")
      assert_equal(
        [
          AtlasEngine::It::AddressImporter::Corrections::OpenAddress::CityCorrector,
          AtlasEngine::It::AddressImporter::Corrections::OpenAddress::ProvinceCorrector,
        ],
        country_profile.ingestion.correctors(source: "open_address"),
      )
    end

    test "#correctors returns an empty array when an unknown source is provided" do
      assert_equal [], CountryProfile.for("JP").ingestion.correctors(source: "bogus")
    end

    test "#validation.validation_exclusions returns an array of exclusion class names for a given component" do
      country_profile = CountryProfile.for("US")
      assert_equal [], country_profile.validation.validation_exclusions(component: "street")
    end

    test "#validation_exclusions returns an empty array when an unknown component is provided" do
      assert_equal [], CountryProfile.for("US").validation.validation_exclusions(component: "bogus")
    end

    test "#validation.enabled returns false by default" do
      assert_not CountryProfile.for("AD").validation.enabled
    end

    test "#validation.enabled returns true when defined per country" do
      assert CountryProfile.for("US").validation.enabled
    end

    test "#validation.partial_postal_code_range returns a postal code range for a given length" do
      country_profile = CountryProfile.for("AR")
      assert_equal 1..4, country_profile.validation.partial_postal_code_range(4)
    end

    test "#validation.normalized_components returns an array of components for a given country" do
      assert_equal ["region2", "region3", "region4", "city_aliases.alias", "suburb", "street_decompounded"],
        CountryProfile.for("DE").validation.normalized_components
    end

    test "#decompounding_patterns returns an array of patterns if the profile defines some for a given field" do
      profile = CountryProfile.for("DE")
      assert_not_empty profile.decompounding_patterns(:street)
    end

    test "#decompounding_patterns returns an empty array if the profile does not define patterns for a given field" do
      de_profile = CountryProfile.for("DE")
      ca_profile = CountryProfile.for("CA")

      assert_empty de_profile.decompounding_patterns(:city)
      assert_empty ca_profile.decompounding_patterns(:street)
    end

    test ".add_default_paths adds paths to the list of default paths" do
      default_paths = CountryProfile.default_paths.dup
      CountryProfile.add_default_paths(["abc"])
      assert_equal(default_paths << "abc", CountryProfile.default_paths)
    end

    test ".add_default_paths mutates the list of default paths" do
      default_paths = CountryProfile.default_paths
      CountryProfile.add_default_paths(["abc"])
      assert_same(default_paths, CountryProfile.default_paths)
    end

    test ".add_country_paths adds paths to the list of country paths" do
      country_paths = CountryProfile.country_paths.dup
      CountryProfile.add_country_paths(["abc"])
      assert_equal(country_paths << "abc", CountryProfile.country_paths)
    end

    test ".add_country_paths mutates the list of country paths" do
      country_paths = CountryProfile.country_paths
      CountryProfile.add_country_paths(["abc"])
      assert_same(country_paths, CountryProfile.country_paths)
    end

    test ".reset! resets the list of default and country paths" do
      CountryProfile.reset!
      assert_empty CountryProfile.default_paths
      assert_empty CountryProfile.country_paths
    end

    test ".default_attributes merges multiple default files in order provided" do
      default_content = <<-YAML
        id: DEFAULT
        feature:
          name: "sample"
          assets: "storage/assets"
      YAML

      default_file = Tempfile.new("default")
      default_file.write(default_content)
      default_file.rewind

      override_content = <<-YAML
        id: DEFAULT
        feature:
          assets: "storage/new_assets"
          enabled: true
      YAML

      override_file = Tempfile.new("override")
      override_file.write(override_content)
      override_file.rewind

      CountryProfile.reset!
      CountryProfile.default_paths = [default_file.path, override_file.path]

      assert_equal(
        {
          "id" => "DEFAULT",
          "feature" => {
            "name" => "sample",
            "assets" => "storage/new_assets",
            "enabled" => true,
          },
        },
        CountryProfile.default_attributes,
      )
    end

    test "Country profiles merges multiple profiles of the same country in the order provided" do
      us_content = <<-YAML
        id: XX
        feature:
          name: "sample"
      YAML

      us_file = Tempfile.new("default")
      us_file.write(us_content)
      us_file.rewind

      override_content = <<-YAML
        id: XX
        feature:
          name: "new sample"
          enabled: true
        feature_2:
          valid?: true
      YAML

      override_file = Tempfile.new("override")
      override_file.write(override_content)
      override_file.rewind

      CountryProfile.reset!
      CountryProfile.country_paths = [us_file.path, override_file.path]

      assert_equal(
        {
          "id" => "XX",
          "feature" => {
            "name" => "new sample",
            "enabled" => true,
          },
          "feature_2" => {
            "valid?" => true,
          },
        },
        CountryProfile.find("XX").attributes,
      )
    end

    test "Countries having both a base country profile and locale extensions produce base and localized variants" do
      base_content = <<-YAML
        id: XX
        feature:
          label: "label"
          name: "sample"
      YAML

      base_file = Tempfile.new("xx")
      base_file.write(base_content)
      base_file.rewind

      locale_content = <<-YAML
        id: XX_YY
        feature:
          name: "new sample"
          enabled: true
        feature_2:
          valid?: true
      YAML

      locale_file = Tempfile.new("yy")
      locale_file.write(locale_content)
      locale_file.rewind

      CountryProfile.reset!
      CountryProfile.country_paths = [base_file.path]
      CountryProfile.locale_paths = [locale_file.path]

      assert_equal(
        {
          "id" => "XX",
          "feature" => {
            "label" => "label",
            "name" => "sample",
          },
        },
        CountryProfile.find("XX").attributes,
      )

      assert_equal(
        {
          "id" => "XX_YY",
          "feature" => {
            "label" => "label",
            "name" => "new sample",
            "enabled" => true,
          },
          "feature_2" => {
            "valid?" => true,
          },
        },
        CountryProfile.find("XX_YY").attributes,
      )
    end

    test ".for creates an instance of the child class" do
      SampleChildProfile.reset!
      assert_equal(SampleChildProfile, SampleChildProfile.for("US").class)
    end

    test "creates an attribute method if a corresponding method is not already defined" do
      us_content = <<-YAML
        id: US
        feature:
          name: "sample"
      YAML

      us_file = Tempfile.new("default")
      us_file.write(us_content)
      us_file.rewind

      CountryProfile.reset!
      CountryProfile.country_paths = [us_file.path]

      assert_equal({ "name" => "sample" }, CountryProfile.for("US").feature)
    end

    test "attribute methods do not override defined methods" do
      SampleChildProfile.reset!
      assert_equal(CountryProfileValidationSubset, SampleChildProfile.for("US").validation.class)
    end
  end
end
