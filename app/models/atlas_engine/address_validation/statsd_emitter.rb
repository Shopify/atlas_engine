# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class StatsdEmitter
      extend T::Sig
      attr_reader :address, :result, :components

      sig { params(address: AbstractAddress, result: Result, components: T.nilable(T::Array[Symbol])).void }
      def initialize(address:, result:,
        components: [:country, :province, :zip, :city, :street, :building_number, :phone])
        @address = address
        @result = result
        @components = components
      end

      sig { void }
      def run
        components.each do |component|
          emit(component)
        end
      end

      sig { params(component: Symbol).void }
      def emit(component)
        concerns = component_concerns(component)
        ending_breadcrumb = concerns.present? ? "invalid" : "valid"

        country_code = if address.country_code.blank? || !Worldwide.region(code: address.country_code).country?
          "no_country"
        else
          Worldwide.region(code: address.country_code).iso_code
        end

        I18n.with_locale("en") do
          tags = {
            country: country_code,
            component: component,
          }.compact

          if concerns.empty?
            StatsD.increment("AddressValidation.#{ending_breadcrumb}", tags: tags)
          else
            concerns.each do |concern|
              tags.merge!(concern.attributes.slice(:code, :type))

              StatsD.increment("AddressValidation.#{ending_breadcrumb}", tags: tags)
            end
          end
        end

        nil
      end

      sig { params(component: Symbol).returns(T::Array[Concern]) }
      def component_concerns(component)
        if component.equal?(:street)
          result.concerns.select do |c|
            c.attributes[:code] =~ /^(address1|address2|street).*/
          end
        elsif component.equal?(:building_number)
          result.concerns.select do |c|
            c.attributes[:code] =~ /^(missing_building_number).*/
          end
        else
          result.concerns.select { |c| c.attributes[:code] =~ /^#{component}.*/ }
        end
      end
    end
  end
end
