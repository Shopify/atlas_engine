# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class LocaleFormatHelperTest < ActiveSupport::TestCase
    def setup
      @country_code = "CA"
      @locale = "en"
    end

    test "format_locale returns nil if locale is blank" do
      assert_nil LocaleFormatHelper.format_locale(nil)
    end

    test "format_locale resolves a SupportedLocale to standard locale format" do
      assert_equal "pt-BR", LocaleFormatHelper.format_locale("PT-BR")
    end

    test "format_locale does not change an input that was not a SupportedLocale" do
      assert_equal "potato", LocaleFormatHelper.format_locale("potato")
    end
  end
end
