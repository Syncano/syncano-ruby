require 'syncano/resources/concerns/routing'
require 'syncano/resources/concerns/associations'

module Syncano
  module Resources
    class Base
      include ActiveAttr::Model
      include ActiveAttr::Dirty
      include Syncano::Resources::RoutingConcern
      include Syncano::Resources::AssociationsConcern

      attr_reader :destroyed

      def initialize(connection, attributes = {}, scope_parameters = {})
        self.connection = connection
        reinitialize!(attributes)
        apply_defaults
      end

      def new_record?
        primary_key.blank?
      end

      def saved?
        !new_record? && attributes == saved_attributes
      end

      def self.all(connection, scope_parameters = {})
        check_resource_method_existance!(:index)

        response = connection.request(:get, collection_path(scope_parameters))
        response['objects'].collect do |resource_attributes|
          new(connection, resource_attributes)
        end
      end

      def self.first(connection, scope_parameters = {})
        all(connection, scope_parameters).first
      end

      def self.last(connection, scope_parameters = {})
        all(connection, scope_parameters).last
      end

      def self.find(connection, pk, scope_parameters = {})
        check_resource_method_existance!(:show)

        response = connection.request(:get, member_path(pk, scope_parameters))
        new(connection, response)
      end

      def self.create(connection, attributes = {}, scope_parameters = {})
        check_resource_method_existance!(:create)

        new(connection, attributes, scope_parameters).save
      end

      def update_attributes(attributes)
        check_resource_method_existance!(:update)
        raise(Syncano::Error.new('record is not saved')) if new_record?

        self.attributes = attributes
        self.save
      end

      def save
        # TODO Call validation here
        apply_forced_defaults!

        if new_record?
          response = connection.request(:post, collection_path, select_create_attributes)
        else
          response = connection.request(:put, member_path, select_update_attributes)
        end

        reinitialize!(response)
      end

      def destroy
        check_resource_method_existance!(:destroy)
        connection.request(:delete, member_path)
        mark_as_destroyed!
      end

      def reload!
        raise(Syncano::Error.new('record is not saved')) if new_record?

        response = connection.request(:get, member_path)
        reinitialize!(response)
      end

      def select_create_attributes
        attributes = self.attributes.select { |name, value| self.class.create_writable_attributes.include?(name.to_sym) }
        self.class.map_attributes_values(attributes)
      end

      def select_update_attributes
        attributes = self.attributes.select{ |name, value| self.class.update_writable_attributes.include?(name.to_sym) }
        self.class.map_attributes_values(attributes)
      end

      def self.map_attributes_values(attributes)
        attributes.each do |name, value|
          if value.is_a?(Hash)
            attributes[name] = value.to_json
          end
        end

        attributes
      end

      private

      class_attribute :resource_definition, :create_writable_attributes, :update_writable_attributes
      attr_accessor :connection, :saved_attributes
      attr_writer :destroyed

      def reinitialize!(attributes = {})
        attributes = HashWithIndifferentAccess.new(attributes)

        initialize_routing(attributes)
        initialize_associations(attributes)

        self.attributes.clear
        self.attributes = attributes.except!(:links)
        mark_as_saved! unless new_record?

        self
      end

      def self.map_member_name_to_resource_class(name)
        "::Syncano::Resources::#{name.camelize}".constantize
      end

      def self.map_collection_name_to_resource_class(name)
        map_member_name_to_resource_class(name.singularize)
      end

      def apply_forced_defaults!
        self.class.attributes.each do |attr_name, attr_definition|
          if read_attribute(attr_name).blank? && attr_definition[:force_default]
            write_attribute(attr_name, attr_definition[:default])
          end
        end
      end

      def mark_as_saved!
        raise(Syncano::Error.new('primary key is blank')) if new_record?

        self.saved_attributes = attributes.dup
        self
      end

      def mark_as_destroyed!
        self.destroyed = true
      end
    end
  end
end