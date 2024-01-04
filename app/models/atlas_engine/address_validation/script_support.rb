# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module ScriptSupport
      include LogHelper
      extend T::Sig

      sig { params(address: AbstractAddress).returns(T::Boolean) }
      def supported_script?(address)
        return false if address.country_code.blank?

        validation_script_restrictions = CountryProfile.for(T.must(address.country_code)).validation.script_restrictions
        return true if validation_script_restrictions.empty?

        scripts = Worldwide.scripts.identify(text: "#{address.address1} #{address.address2} #{address.city}")
        return true if scripts.empty?

        return true if scripts.all? { |s| validation_script_restrictions.include?(s) }

        log_unsupported_script(T.must(address.country_code), scripts)

        false
      end

      private

      sig { params(country_code: String, scripts: T::Array[String]).void }
      def log_unsupported_script(country_code, scripts)
        log_info("Address contains unsupported script(s): #{scripts}")

        tags = [
          "country_code:#{country_code}",
          "scripts:#{scripts.sort.join(", ")}",
        ]
        StatsD.increment("AddressValidation.unsupported_script", sample_rate: 1.0, tags: tags)
      end
    end
  end
end
