# typed: false
# frozen_string_literal: true

module AtlasEngine
  module HandlesBlob
    extend ActiveSupport::Concern

    class BlobNotFoundError < StandardError; end

    included do
      def storage_service
        ActiveStorage::Blob.service
      end

      def blob_exists?(key)
        storage_service.exist?(key)
      end

      def download(key, &block)
        raise BlobNotFoundError unless blob_exists?(key)

        storage_service.open(key, verify: false, &block)
      end
    end
  end
end
