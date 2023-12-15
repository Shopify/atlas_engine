# typed: false
# frozen_string_literal: true

require "zip"

module AtlasEngine
  module ActiveStorageTestHelper
    include ActiveJob::TestHelper

    def setup_zip_blob(key:)
      file = Tempfile.new

      ::Zip::File.open(file, create: true) do |zipfile|
        zipfile.get_output_stream(key) { |f| f.write("csv;content") }
      end

      File.open(file) do |file_io|
        ActiveStorage::Blob.service.upload(key, file_io)
      end

      file.unlink
    end

    def teardown_blob(key:)
      ActiveStorage::Blob.service.delete(key)
    end
  end
end
