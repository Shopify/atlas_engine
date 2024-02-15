# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## How do I make a good changelog?

### Guiding Principles

- Changelogs are for humans, not machines.
- There should be an entry for every single version.
- The same types of changes should be grouped.
- Versions and sections should be linkable.
- The latest version comes first.
- The release date of each version is displayed.
- Mention whether you follow Semantic Versioning.

### Types of changes

- Added for new features.
- Changed for changes in existing functionality.
- Deprecated for soon-to-be removed features.
- Removed for now removed features.
- Fixed for any bug fixes.
- Security in case of vulnerabilities.

## [Unreleased]

- Rearrange storage of feature mappers in country profiles [#137](https://github.com/Shopify/atlas_engine/pull/137)
- Remove session from Validation::Exclusion [#135](https://github.com/Shopify/atlas_engine/pull/135)
- Send parsings and country profile into QueryBuilder initializer [#134](https://github.com/Shopify/atlas_engine/pull/134)
- Remove the unnecessary instantiation of worldwide region from CountryProfile.for [#130](https://github.com/Shopify/atlas_engine/pull/130)

---

[0.4.0] - 2024-02-13

- Add trilogy to gemspec [#127](https://github.com/Shopify/atlas_engine/pull/127)
- Migrate from `mysql2` database adapter to `trilogy` [#123](https://github.com/Shopify/atlas_engine/pull/123)

[0.3.0] - 2024-02-08

- Add `zip_prefix_length` config in country profile to tune zip fuzzy search [#112](https://github.com/Shopify/atlas_engine/pull/112)
- Add address parser and synonyms for Spain [#111](https://github.com/Shopify/atlas_engine/pull/111)
- Update FR country profile to set has_provinces to false [#108](https://github.com/Shopify/atlas_engine/pull/108)
- Add `.match?` method to `FieldComparisonBase` [#99](https://github.com/Shopify/atlas_engine/pull/99)
- Country specific field comparison classes [#98](https://github.com/Shopify/atlas_engine/pull/98)
- Update `AddressComparison.<field_comparison>` methods to return `FieldComparisonBase` instances instead of `Token::Sequence::Comparison` [#95](https://github.com/Shopify/atlas_engine/pull/95)
- Address TestCase#fixture_path deprecation [#94](https://github.com/Shopify/atlas_engine/pull/94)
- Address parser test cleanup [#92](https://github.com/Shopify/atlas_engine/pull/92)
- Split field comparison logic into their respective classes [#93](https://github.com/Shopify/atlas_engine/pull/93)
- Improved validation suggestions for Luxembourg [#82](https://github.com/Shopify/atlas_engine/pull/82)
- Store a duplicate of Result in ConcernRecord [#85](https://github.com/Shopify/atlas_engine/pull/85)
- Introduce parser and city exclusion for South Korea [#79](https://github.com/Shopify/atlas_engine/pull/79)
- Prepare PT for es validation (address parser, synonyms, zip exclusion) [#46](https://github.com/Shopify/atlas_engine/pull/46)
- Improve ingestion and validation for Slovenia [#76](https://github.com/Shopify/atlas_engine/pull/76)
- Enable Sorbet/ForbidTStruct cop [#78] (https://github.com/Shopify/atlas_engine/pull/78)
- Fix lookup of unmatched_components_suggestion_threshold [#73](https://github.com/Shopify/atlas_engine/pull/73)
- Add city corrector for Faroe Islands [#72](https://github.com/Shopify/atlas_engine/pull/72)
- Configure validation support for Poland [#70](https://github.com/Shopify/atlas_engine/pull/70)
- Make unmatched_components_suggestion_threshold configurable in country profiles [#71](https://github.com/Shopify/atlas_engine/pull/71)
- Include unmatched token length in sequence comparison's "aggregate distance" [#65](https://github.com/Shopify/atlas_engine/pull/65)
- Add an AddressComparsion argument to validation exclusions [#64](https://github.com/Shopify/atlas_engine/pull/64)
- Add comparison policy for cities in CZ [#63](https://github.com/Shopify/atlas_engine/pull/63)
- Allow Exclusions to apply on any address component and add an Exclusion for city validation in Italy [#61](https://github.com/Shopify/atlas_engine/pull/61)
- Allow nil address 2 in BuildingNumberInAddress1OrAddress2 predicate [#57](https://github.com/Shopify/atlas_engine/pull/57)
- Improve indexing for Poland [#56](https://github.com/Shopify/atlas_engine/pull/56)
- Configure sequence comparison policy for South Korea [#58](https://github.com/Shopify/atlas_engine/pull/58)
- Configurable sequence comparison policy [#54](https://github.com/Shopify/atlas_engine/pull/54)
- Emit StatsD validation metric when address_unknown concern is returned [#55](https://github.com/Shopify/atlas_engine/pull/55)
- Enable ES level validation for Slovenia (SI) [#44](https://github.com/Shopify/atlas_engine/pull/44)

[0.2.0] - 2024-01-24

- Use match query for province_code clause in query builder [#45](https://github.com/Shopify/atlas_engine/pull/45)
- Improve validation for Belgium [#47](https://github.com/Shopify/atlas_engine/pull/47)
- Convert all ComparisonHelper functionality into instanced methods [#50](https://github.com/Shopify/atlas_engine/pull/50)
- Update Bermuda city alias assignment and synonyms [#43](https://github.com/Shopify/atlas_engine/pull/43)
- Remove unused validation.city_fields param from country profiles [#42](https://github.com/Shopify/atlas_engine/pull/42)
- Update CandidateResult to factor in all address components in comparisons [#40](https://github.com/Shopify/atlas_engine/pull/40)
- Hook up docker compose to dockerfile that installs analysis-icu plugin in dockerized es [#32](https://github.com/Shopify/atlas_engine/pull/32)
- Add matching_strategy param to logs [#36](https://github.com/Shopify/atlas_engine/pull/36)
- Add custom parser and query builder for CZ to handle addresses with no street names [#34](https://github.com/Shopify/atlas_engine/pull/34)
- Remove the empty building clause from the full address query [#31](https://github.com/Shopify/atlas_engine/pull/31)
- Update italy re-encoding script to discard malformed lines [#33](https://github.com/Shopify/atlas_engine/pull/33)
- Add maintenance task migrations to dummy app [#30](https://github.com/Shopify/atlas_engine/pull/30)
- Update CH country profile with an address parser and has_provinces:false[#28](https://github.com/Shopify/atlas_engine/pull/28)
- Remove corrector to fix encoding issues in Italy's OA data [#27](https://github.com/Shopify/atlas_engine/pull/27)
- Update IT to use DK address parser [#25](https://github.com/Shopify/atlas_engine/pull/25)
- Add a script to fix encoding errors in the italian source file [#24](https://github.com/Shopify/atlas_engine/pull/24)
- Update datastore to load the country profile with locale, and update Saudi Arabia to use normalized components instead of the normalizer class [#23](https://github.com/Shopify/atlas_engine/pull/23)
- Change the name of the active support notification to be consistent with `atlas_engine`[#18](https://github.com/Shopify/atlas_engine/pull/18)
- Add corrector to fix encoding issues in Italy's OA data and updated Italy's mapper to not titleize the street names [#17](https://github.com/Shopify/atlas_engine/pull/17)

[0.1.2] - 2024-01-18

- Update references to point to new repo url

[0.1.1] - 2024-01-17

- Gemspec fixes for changelog url and required ruby version

[0.1.0] - 2024-01-17

- Initial release of Atlas Engine
