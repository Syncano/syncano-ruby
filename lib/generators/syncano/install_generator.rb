module Syncano
  # Module for generators used implemented in the gem
  module Generators
    # Install generator used for initializing gem in a Rails application
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      # Copies templates for initializers
      def create_initializers
        Dir["#{self.class.source_root}/initializers/*.rb"].each do |filepath|
          name = File.basename(filepath)
          template "initializers/#{name}", "config/initializers/#{name}"
        end
      end
    end
  end
end