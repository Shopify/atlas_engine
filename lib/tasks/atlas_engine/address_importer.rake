# typed: false
# frozen_string_literal: true

namespace :atlas_engine do
  namespace :address_importer do
    desc "Import addresses from a CSV file."
    task run: :environment do
      file_path = ENV["file_path"]
      if file_path.nil?
        raise ArgumentError, "file_path variable is required for csv import"
      end

      puts "\nRunning the Address Importer."

      AtlasEngine::PostAddressImporter.new(file_path).import

      puts "\nAddress Importer task complete."
    end
  end
end
