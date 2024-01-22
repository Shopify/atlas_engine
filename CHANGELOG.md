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
- Add considerations for unmatched tokens in comparison [#37](https://github.com/Shopify/atlas_engine/pull/37)
- Update Bermuda city alias assignment and synonyms [#43](https://github.com/Shopify/atlas_engine/pull/43)
- Remove unused validation.city_fields param from country profiles [#42](https://github.com/Shopify/atlas_engine/pull/42)
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
---

[0.1.2] - 2024-01-18

- Update references to point to new repo url

[0.1.1] - 2024-01-17

- Gemspec fixes for changelog url and required ruby version

[0.1.0] - 2024-01-17

- Initial release of Atlas Engine
