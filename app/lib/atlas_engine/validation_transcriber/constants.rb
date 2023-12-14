# typed: true
# frozen_string_literal: true

require "singleton"

module AtlasEngine
  module ValidationTranscriber
    class Constants
      extend T::Sig
      include Singleton

      TRANSCRIBER_FILE = File.join(AtlasEngine::Engine.root, "db/data/transcriber.yml").freeze

      class << self
        def instance
          @instance ||= new
        end

        def create_accessor_methods(yaml_hash)
          yaml_hash.each do |constant_name, _|
            define_method(constant_name.to_s) do
              @data[constant_name]
            end
          end
        end
      end

      sig { void }
      def initialize
        @data ||= load_yaml_file(TRANSCRIBER_FILE)
        self.class.create_accessor_methods(@data)
      end

      sig { params(constant_type: Symbol, value: T.nilable(String)).returns(T::Boolean) }
      def known?(constant_type, value)
        constants = @data[constant_type]
        return false if constants.blank? || value.blank?

        downcased = value.delete_suffix(".").downcase
        constants.key?(downcased.to_sym) || constants.value?(downcased)
      end

      private

      def load_yaml_file(filename)
        YAML.load_file(filename, freeze: true).deep_symbolize_keys
      end
    end
  end
end
