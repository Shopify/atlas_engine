# typed: ignore
# frozen_string_literal: true

module AtlasEngine
  # Generator used to set up the engine in the host application. It handles
  # mounting the engine and installing migrations.
  #
  # @api private
  class InstallGenerator < Rails::Generators::Base
    # Mounts the engine in the host application's config/routes.rb
    def mount_engine
      route("mount AtlasEngine::Engine => \"/atlas_engine/\"")
    end

    # Copies engine migrations to host application and migrates the database
    def install_migrations
      rake("atlas_engine:install:migrations")
      rake("db:migrate")
    end
  end
end
