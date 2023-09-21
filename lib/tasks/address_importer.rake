
namespace :address_importer do
  desc "Import addresses from a CSV file."
  task run: :environment do
    file_path = ENV["file_path"]
    if file_path.nil?
      raise ArgumentError.new("file_path variable is required for csv import")
    end

    puts "\nRunning the Address Importer."

    AtlasEngineTestOne::PostAddressImporter.new(file_path).import

    puts "\nAddress Importer task complete."
  end
end
