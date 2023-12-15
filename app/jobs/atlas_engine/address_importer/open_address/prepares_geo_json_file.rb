# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module OpenAddress
      module PreparesGeoJsonFile
        extend T::Sig
        include HandlesBlob

        ROOT_FOLDER = "openaddress"

        sig { params(block: T.proc.void).void }
        def download_geojson(&block)
          if @geojson_path.exist?
            yield
          else
            download_from_activestorage do |local_path|
              @geojson_path = local_path
              yield
            end
          end
        end

        private

        sig do
          params(block: T.proc.params(arg0: Pathname).void).void
        end
        def download_from_activestorage(&block)
          root = Pathname.new(ROOT_FOLDER)
          key = root.join(@geojson_path.basename).to_s

          download(key) do |fp|
            yield Pathname.new(fp.path)
          end
        end
      end
    end
  end
end
