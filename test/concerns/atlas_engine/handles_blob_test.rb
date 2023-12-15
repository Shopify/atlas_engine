# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class HandlesBlobTest < ActiveSupport::TestCase
    class DummyJob
      include HandlesBlob
    end

    setup do
      @job = DummyJob.new

      @blob_key = SecureRandom.hex
      ActiveStorage::Blob.service.upload(@blob_key, StringIO.new("contents"))
    end

    teardown do
      ActiveStorage::Blob.service.delete(@blob_key)
    end

    test "downloaded blob can be read within the block" do
      temp_file_path = nil

      @job.download(@blob_key) do |file|
        temp_file_path = file.path
        assert File.file?(file.path)
        assert_equal "contents", file.read
      end

      assert_not File.exist?(temp_file_path)
      assert ActiveStorage::Blob.service.exist?(@blob_key)
    end
  end
end
