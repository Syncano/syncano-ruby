module Syncano
  module Resources
    module RoutingConcern
      PARAMETER_REGEXP = /\{([^}]+)\}/

      extend ActiveSupport::Concern

      included do
        private

        attr_accessor :member_path, :scope_parameters

        {
          index: { type: :collection, method: :get },
          create: { type: :collection, method: :post },
          show: { type: :member, method: :get },
          update: { type: :member, method: :put },
          destroy: { type: :member, method: :delete }
        }.each do |name, parameters|

          define_singleton_method(name.to_s + '_implemented?') do
            send("has_#{parameters[:type]}_actions?") and
              resource_definition[parameters[:type]][:http_methods].include?(parameters[:method].to_s)
          end
        end
      end

      module ClassMethods
        def extract_scope_parameters(path)
          return {} if scope_parameters_names.empty?

          pattern = collection_path_schema.gsub('/', '\/')

          scope_parameters_names.each do |parameter_name|
            pattern.sub!("{#{parameter_name}}", '([^\/]+)')
          end

          pattern = Regexp.new(pattern)
          parameter_values = path.scan(pattern).first

          Hash[*scope_parameters_names.zip(parameter_values).flatten]
        end

        def extract_primary_key(path)
          pattern = member_path_schema.gsub('/', '\/')

          scope_parameters_names.each do |parameter_name|
            pattern.sub!("{#{parameter_name}}", '([^\/]+)')
          end

          pattern.sub!("{#{primary_key_name}}", '([^\/]+)')

          pattern = Regexp.new(pattern)
          parameter_values = path.scan(pattern).first
          parameter_values.last
        end

        private

        def collection_path_schema
          resource_definition[:collection][:path].dup
        end

        def member_path_schema
          resource_definition[:member][:path].dup
        end

        def scope_parameters_names
          collection_path_schema.scan(PARAMETER_REGEXP).collect{ |matches| matches.first.to_sym }
        end

        def has_collection_actions?
          resource_definition[:collection].present?
        end

        def has_member_actions?
          resource_definition[:member].present?
        end

        def check_resource_method_existance!(method_name)
          raise(NoMethodError.new) unless send("#{method_name}_implemented?")
        end

        def primary_key_name
          resource_definition[:member][:path].scan(PARAMETER_REGEXP).last.first if has_member_actions?
        end

        def collection_path(scope_parameters = {})
          path = collection_path_schema

          scope_parameters_names.each do |scope_parameter_name|
            path.sub!("{#{scope_parameter_name}}", scope_parameters[scope_parameter_name])
          end

          path
        end

        def member_path(pk, scope_parameters = {})
          path = member_path_schema

          scope_parameters_names.each do |scope_parameter_name|
            path.sub!("{#{scope_parameter_name}}", scope_parameters[scope_parameter_name])
          end

          path.sub!("{#{primary_key_name}}", pk.to_s)

          path
        end

        def remove_version_from_path(path)
          path.gsub("/#{::Syncano::Connection::API_VERSION}/", '')
        end
      end

      private

      def initialize_routing(attributes)
        self.member_path = attributes[:links].try(:[], :self)
      end

      def collection_path
        self.class.collection_path(scope_parameters)
      end

      def member_path
        self.class.member_path(primary_key, scope_parameters)
      end

      def primary_key
        self.class.extract_primary_key(association_paths[:self])
      end

      def check_resource_method_existance!(method_name)
        self.class.send(:check_resource_method_existance!, method_name)
      end
    end
  end
end