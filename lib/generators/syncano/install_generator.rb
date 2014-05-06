module Syncano
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def create_initializers
        Dir["#{self.class.source_root}/initializers/*.rb"].each do |filepath|
          name = File.basename(filepath)
          template "initializers/#{name}", "config/initializers/#{name}"
        end
      end
    end
  end
end