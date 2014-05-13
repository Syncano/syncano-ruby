class Syncano
  module Resources
    class Base
      attr_accessor :attributes
      attr_reader :id, :errors, :destroyed

      # Constructor for base resource
      # @param [Syncano::Client] client
      # @param [Hash] attributes used in making requests to api (ie. parent id)
      def initialize(client, attributes = {}, errors = [])
        super()

        @attributes = ActiveSupport::HashWithIndifferentAccess.new(attributes)
        @saved_attributes = ActiveSupport::HashWithIndifferentAccess.new
        self.id = @attributes.delete(:id)

        self.client = client
        self.errors = errors

        mark_as_saved! if id.present? && errors.empty?
      end

      def attributes=(attributes)
        @attributes.merge!(attributes)
      end

      # Wrapper for api "get" method
      # Returns all objects from Syncano
      # @return [Syncano::Response]
      def self.all(client, scope_parameters = {}, conditions = {})
        check_class_method_existance!(__method__)
        response = make_request(client, __method__, conditions.merge(scope_parameters))

        if response.status
          response.data.to_a.collect { |attributes| self.new(client, attributes.merge(scope_parameters)) }
        end
      end

      def self.count(client, scope_parameters = {}, conditions = {})
        check_class_method_existance!(__method__)
        all(client, scope_parameters, conditions).count
      end

      # Wrapper for api "get_one" method
      # Returns one object from Syncano
      # @param [Integer, Hash] key
      # @return [Syncano::Resource::Base]
      def self.find(client, id, scope_parameters = {}, conditions = {})
        check_class_method_existance!(__method__)
        find_by(client, conditions.merge(scope_parameters.merge(id: id)))
      end

      # Wrapper for api "new" method
      # Creates object in Syncano
      # @return [Syncano::Response]
      def self.create(client, attributes)
        check_class_method_existance!(__method__)
        response = make_request(client, __method__, attributes_to_sync(attributes))

        if response.status
          self.new(client, map_to_scope_parameters(attributes).merge(response.data))
        end
      end

      # Wrapper for api "update" method
      # Updates object in Syncano
      # @param [Integer, Hash] key
      # @return [Syncano::Response]
      def update(attributes)
        check_instance_method_existance!(__method__)
        response = self.class.make_member_request(client, __method__, self.class.attributes_to_sync(attributes).merge(id: id))

        if response.status
          response.data.delete('id')
          self.attributes = scope_parameters.merge(response.data)
          mark_as_saved!
        else
          self.errors << 'Something went wrong'
        end

        self
      end

      def save
        check_instance_method_existance!(__method__)
        if new_record?
          object = self.class.create(client, attributes)
          self.id = object.id
          self.attributes = object.attributes
          self.errors = object.errors
          mark_as_saved! if errors.empty?
        else
          self.update(attributes)
        end

        self
      end

      # Wrapper for api "delete" method
      # Destroys object in Syncano
      # @param [Integer, Hash] key
      # @return [Syncano::Response]
      def destroy
        check_instance_method_existance!(__method__)
        response = self.class.make_member_request(client, __method__, { id: id }.merge(scope_parameters))
        self.destroyed = response.status
        self
      end

      def new_record?
        id.nil?
      end

      def saved?
        !new_record? && attributes == saved_attributes
      end

      def destroyed?
        !!destroyed
      end

      def reload!
        unless new_record?
          reloaded_object = self.class.find(client, primary_key, scope_parameters)
          self.attributes = reloaded_object.attributes
          self.errors = []
        end

        self
      end

      private

      attr_accessor :client, :saved_attributes
      attr_writer :id, :errors, :destroyed

      # Converts resource class name to corresponding Syncano resource name
      # @return [String]
      def self.api_resource
        syncano_model_name || to_s.split('::').last.downcase
      end

      # Converts Syncano gem method to corresponding Syncano api method
      # @param [String] method_name
      # @return [String]
      def self.api_method(method_name)
        mapping = { all: :get, find_by: :get_one, create: :new, update: :update, destroy: :delete }
        mapping.keys.include?(method_name.to_sym) ? mapping[method_name.to_sym] : method_name
      end

      # Calls request to api through client object
      # @param [String] method_name
      # @param [Hash] attributes for specific type of object
      # @return [Syncano::Response]
      def self.make_request(client, method_name, attributes = {})
        response = client.make_request(api_resource, api_method(method_name), attributes)
      end

      # Calls request to api for methods operating on a particular object
      # @param [Integer, Hash] key
      # @param [String] method_name
      # @param [Hash] attributes for specific type of object
      # @return [Syncano::Response]
      def self.make_member_request(client, method_name, attributes = {})
        if attributes.keys.include?(:key)
          key_attributes = { "#{api_resource}_key" => attributes[:key].to_s }
        elsif attributes.keys.include?(:name)
          key_attributes = { "#{api_resource}_name" => attributes[:name].to_s }
        else
          key_attributes = { "#{api_resource}_id" => attributes[:id].to_s }
        end

        make_request(client, method_name, attributes.merge(key_attributes))
      end

      def self.find_by(client, attributes)
        response = make_member_request(client, __method__, attributes)

        if response.status
          self.new(client, attributes.merge(response.data))
        end
      end

      class_attribute :syncano_model_name, :scope_parameters, :crud_class_methods, :crud_instance_methods

      self.syncano_model_name = nil
      self.scope_parameters = []
      self.crud_class_methods = [:all, :find, :new, :create, :count]
      self.crud_instance_methods = [:save, :update, :destroy]

      def self.map_to_scope_parameters(attributes)
        Hash[scope_parameters.map{ |sym| [sym, attributes[sym]]}]
      end

      def scope_parameters
        self.class.map_to_scope_parameters(attributes)
      end

      def primary_key
        id
      end

      def mark_as_saved!
        self.saved_attributes = attributes.dup
      end

      def self.attributes_to_sync(attributes = {})
        attributes
      end

      def attributes_to_sync
        self.class.attributes_to_sync(attributes)
      end

      def self.check_class_method_existance!(method_name)
        raise NoMethodError.new("undefined method `#{method_name}' for #{to_s}") unless crud_class_methods.include?(method_name.to_sym)
      end

      def check_instance_method_existance!(method_name)
        raise NoMethodError.new("undefined method `#{method_name}' for #{to_s}") unless crud_instance_methods.include?(method_name.to_sym)
      end
    end
  end
end