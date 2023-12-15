# typed: false
# frozen_string_literal: true

module AtlasEngine
  module IndexConfigurationHelper
    def write_temp_config_file(dir:, handle:, yaml_content:)
      path = File.join(dir, "#{handle}.yml")

      File.open(path, "w") do |file|
        file.write(yaml_content)
      end
    end

    def with_temp_config_dir
      Dir.mktmpdir(self.class.name) do |dir|
        FileUtils.cp(File.join(IndexConfigurationFactory::INDEX_CONFIGURATIONS_ROOT, "default.yml"), dir)
        yield dir
      end
    end
  end
end
