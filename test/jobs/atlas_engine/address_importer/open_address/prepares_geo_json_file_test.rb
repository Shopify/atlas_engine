# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporter
    module OpenAddress
      class PreparesGeoJsonFileTest < ActiveSupport::TestCase
        class DummyJob < ApplicationJob
          include PreparesGeoJsonFile
          attr_reader :geojson_path

          around_perform :prepare_geojson_file

          def prepare_geojson_file(&block)
            @geojson_path = Pathname.new(argument(:file_path))
            download_geojson(&block)
          end

          def perform(_params); end
        end

        test "#download_geojson will not download a file if it already exists" do
          file_path = "tmp/local/file.gz"
          FileUtils.mkdir_p(File.dirname(file_path))
          FileUtils.touch(file_path)

          downloader = DummyJob.new(file_path: file_path)
          downloader.expects(:download_from_activestorage).never

          downloader.perform_now

          assert_equal file_path, downloader.geojson_path.to_s
        end

        test "#download_geojson will download a file and reassign geojson_path if it does not exist locally" do
          downloader = DummyJob.new(file_path: "does/not/exist.gz")

          tempfile = Tempfile.new(["exist", ".gz"])
          downloader.expects(:download).once.with("openaddress/exist.gz").yields(tempfile)

          downloader.perform_now

          assert_equal tempfile.path, downloader.geojson_path.to_s
        end

        test "#download_geojson will return an error if the file does not exist locally" do
          downloader = DummyJob.new(file_path: "does/not/exist.gz")

          assert_raises(HandlesBlob::BlobNotFoundError) do
            downloader.perform_now
          end
        end
      end
    end
  end
end
