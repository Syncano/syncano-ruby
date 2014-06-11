class Syncano
  # Module used as a scope for classes representing resources
  module Resources
    # Base resource used for inheritance
    class Base
      attr_accessor :attributes
      attr_reader :id, :destroyed

      # Constructor for base resource
      # @param [Syncano::Clients::Base] client
      # @param [Hash] attributes used in making requests to api (ie. parent id)
      def initialize(client, attributes = {})
        super()

        @attributes = ActiveSupport::HashWithIndifferentAccess.new(attributes)
        @saved_attributes = ActiveSupport::HashWithIndifferentAccess.new
        self.id = @attributes.delete(:id)

        self.client = client

        mark_as_saved! if id.present?
      end

      # Attributes setter
      # @param [Hash] attributes
      # @return [Hash]
      def attributes=(attributes)
        @attributes.merge!(attributes)
      end

      # Single attribute getter
      # @param [Symbol, String] attribute_name
      # @return [Object]
      def [](attribute_name)
        attributes[attribute_name]
      end

      # Single attribute setter
      # @param [Symbol, String] attribute_name
      # @param [Object] attribute_value
      # @return [Object]
      def []=(attribute_name, attribute_value)
        attributes[attribute_name] = attribute_value
      end

      # Proxy for preparing batch requests
      # ie. resource.batch.update will prepare BatchQueueElement
      # which invokes batch_update method on resource object
      # @return [Syncano::BatchQueueElement]
      def batch
        ::Syncano::BatchQueueElement.new(self)
      end

      # Wrapper for api "get" method
      # Returns all objects from Syncano
      # @param [Syncano::Clients::Base] client
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Array] which contains Syncano::Resources::Base objects
      def self.all(client, scope_parameters = {}, conditions = {})
        response = perform_all(client, scope_parameters, conditions)
        response.data.to_a.collect do |attributes|
          new(client, attributes.merge(scope_parameters))
        end
      end

      # Returns amount of elements returned from all method
      # @param [Syncano::Clients::Base] client
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Integer]
      def self.count(client, scope_parameters = {}, conditions = {})
        perform_count(client, scope_parameters, conditions)
      end

      # Wrapper for api "get_one" method
      # Returns one object from Syncano
      # @param [Syncano::Clients::Base] client
      # @param [Integer, String] key
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      def self.find(client, key, scope_parameters = {}, conditions = {})
        response = perform_find(client, primary_key_name, key, scope_parameters, conditions)
        new(client, scope_parameters.merge(response.data))
      end

      # Wrapper for api "new" method
      # Creates object in Syncano
      # @param [Syncano::Clients::Base] client
      # @param [Hash] attributes
      # @return [Syncano::Resources::Base]
      def self.create(client, attributes)
        response = perform_create(client, nil, attributes)
        new(client, map_to_scope_parameters(attributes).merge(response.data))
      end

      # Batch version of "create" method
      # @param [Jimson::BatchClient] batch_client
      # @param [Syncano::Clients::Base] client
      # @param [Hash] attributes
      # @return [Syncano::Response]
      def self.batch_create(batch_client, client, attributes)
        perform_create(client, batch_client, attributes)
      end

      # Wrapper for api "update" method
      # Updates object in Syncano
      # @param [Hash] attributes
      # @return [Syncano::Resources::Base]
      def update(attributes)
        response = perform_update(nil, attributes)
        response.data.delete('id')
        self.attributes = scope_parameters.merge(response.data)
        mark_as_saved!
      end

      # Batch version of "update" method
      # @param [Jimson::BatchClient] batch_client
      # @param [Hash] attributes
      # @return [Syncano::Response]
      def batch_update(batch_client, attributes)
        perform_update(batch_client, attributes)
      end

      # Invokes create or update methods
      # @return [Syncano::Resources::Base]
      def save
        response = perform_save(nil)

        if new_record?
          response_data = ActiveSupport::HashWithIndifferentAccess.new(response.data)
          created_object = self.class.new(client, self.class.map_to_scope_parameters(attributes).merge(response_data))

          self.id = created_object.id
          self.attributes.merge!(created_object.attributes)
          mark_as_saved!
        end

        self
      end

      # Batch version of "save" method
      # @param [Jimson::BatchClient] batch_client
      # @return [Syncano::Response]
      def batch_save(batch_client)
        perform_save(batch_client)
      end

      # Wrapper for api "delete" method
      # Destroys object in Syncano
      # @return [Syncano::Resources::Base] marked as destroyed
      def destroy
        response = perform_destroy(nil)
        self.destroyed = response.status
        self
      end

      # Batch version of "destroy" method
      # @param [Jimson::BatchClient] batch_client
      # @return [Syncano::Response]
      def batch_destroy(batch_client)
        perform_destroy(batch_client)
      end

      # Checks whether is newly initialized or not
      # @return [TrueClass, FalseClass]
      def new_record?
        id.nil?
      end

      # Checks whether record is different than stored in Syncano
      # @return [TrueClass, FalseClass]
      def saved?
        !new_record? && attributes == saved_attributes
      end

      # Checks whether record is marked as destroyed
      # @return [TrueClass, FalseClass]
      def destroyed?
        !!destroyed
      end

      # Reloads record from Syncano
      # @return [TrueClass, FalseClass]
      def reload!(conditions = {})
        unless new_record?
          reloaded_object = self.class.find(client, primary_key, scope_parameters, conditions)
          self.attributes.clear
          self.attributes = reloaded_object.attributes
          mark_as_saved!
        end

        self
      end

      private

      class_attribute :syncano_model_name, :scope_parameters, :crud_class_methods, :crud_instance_methods, :primary_key

      self.syncano_model_name = nil
      self.scope_parameters = []
      self.crud_class_methods = [:all, :find, :new, :create, :count]
      self.crud_instance_methods = [:save, :update, :destroy]
      self.primary_key = :id

      attr_accessor :client, :saved_attributes
      attr_writer :id, :destroyed

      # Executes proper all request
      # @param [Syncano::Clients::Base] client
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Syncano::Response]
      def self.perform_all(client, scope_parameters, conditions)
        check_class_method_existance!(:all)
        make_request(client, nil, :all, conditions.merge(scope_parameters))
      end

      # Executes proper count request
      # @param [Syncano::Clients::Base] client
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Syncano::Response]
      def self.perform_count(client, scope_parameters, conditions)
        check_class_method_existance!(:count)
        all(client, scope_parameters, conditions).count
      end

      # Executes proper find request
      # @param [Syncano::Clients::Base] client
      # @param [Symbol, String] key_name
      # @param [Integer, String] key
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Syncano::Response]
      def self.perform_find(client, key_name, key, scope_parameters, conditions)
        check_class_method_existance!(:find)
        make_request(client, nil, :find, conditions.merge(scope_parameters.merge(key_name.to_sym => key)))
      end

      # Executes proper create request
      # @param [Syncano::Clients::Base] client
      # @param [Jimson::BatchClient] batch_client
      # @param [Hash] attributes
      # @return [Syncano::Response]
      def self.perform_create(client, batch_client, attributes)
        check_class_method_existance!(:create)
        make_request(client, batch_client, :create, attributes_to_sync(attributes))
      end

      # Executes proper update request
      # @param [Jimson::BatchClient] batch_client
      # @param [Hash] attributes
      # @return [Syncano::Response]
      def perform_update(batch_client, attributes)
        check_instance_method_existance!(:update)
        self.class.make_request(client, batch_client, :update, scope_parameters.merge(self.class.attributes_to_sync(attributes).merge(self.class.primary_key_name => primary_key)))
      end

      # Executes proper save request
      # @param [Jimson::BatchClient] batch_client
      # @return [Syncano::Response]
      def perform_save(batch_client)
        check_instance_method_existance!(:save)

        if new_record?
          self.class.perform_create(client, batch_client, attributes)
        else
          perform_update(batch_client, attributes)
        end
      end

      # Executes proper destroy request
      # @param [Jimson::BatchClient] batch_client
      # @return [Syncano::Response]
      def perform_destroy(batch_client)
        check_instance_method_existance!(:destroy)
        self.class.make_request(client, batch_client, :destroy, scope_parameters.merge({ self.class.primary_key_name => primary_key }))
      end

      # Converts resource class name to corresponding Syncano resource name
      # @return [String]
      def self.api_resource
        syncano_model_name || to_s.split('::').last.downcase
      end

      # Converts Syncano gem method to corresponding Syncano api method
      # @param [String] method_name
      # @return [String]
      def self.api_method(method_name)
        mapping = { all: :get, find: :get_one, create: :new, update: :update, destroy: :delete }

        method_name = method_name.to_s.gsub('batch_', '')
        mapping.keys.include?(method_name.to_sym) ? mapping[method_name.to_sym] : method_name
      end

      # Calls request to api through client object
      # @param [Syncano::Clients::Base] client
      # @param [Jimson::BatchClient] batch_client
      # @param [String] method_name
      # @param [Hash] attributes
      # @param [String] response_key
      # @return [Syncano::Response]
      def self.make_request(client, batch_client, method_name, attributes = {}, response_key = nil)
        if batch_client.nil?
          client.make_request(api_resource, api_method(method_name), attributes, response_key)
        else
          client.make_batch_request(batch_client, api_resource, api_method(method_name), attributes)
        end
      end

      # Returns scope parameters from provided hash with attributes
      # @param [Hash] attributes
      # @return [Hash]
      def self.map_to_scope_parameters(attributes)
        Hash[scope_parameters.map{ |sym| [sym, attributes[sym]]}]
      end

      # Returns scope parameters from object's attributes
      # @return [Hash]
      def scope_parameters
        self.class.map_to_scope_parameters(attributes)
      end

      # Returns name for primary key
      # @return [Hash]
      def self.primary_key_name
        "#{api_resource}_#{primary_key}".to_sym
      end

      # Returns value of primary key
      # @return [Integer, String]
      def primary_key
        self.class.primary_key == :id ? id : @saved_attributes[self.class.primary_key]
      end

      # Marks record as saved, by copying attributes to saved_attributes
      # @return [Integer, String]
      def mark_as_saved!
        self.saved_attributes = attributes.dup
        self
      end

      # Prepares hash with attributes used in synchronization with Syncano
      # @param [Hash] attributes
      # @return [Hash]
      def self.attributes_to_sync(attributes = {})
        attributes
      end

      # Prepares hash with attributes used in synchronization with Syncano
      # @return [Hash]
      def attributes_to_sync
        self.class.attributes_to_sync(attributes)
      end

      # Checks whether class method is implemented in the resource class
      def self.check_class_method_existance!(method_name)
        raise NoMethodError.new("undefined method `#{method_name}' for #{to_s}") unless crud_class_methods.include?(method_name.to_sym)
      end

      # Checks whether class method is implemented in the resource class
      def check_instance_method_existance!(method_name)
        raise NoMethodError.new("undefined method `#{method_name}' for #{to_s}") unless crud_instance_methods.include?(method_name.to_sym)
      end

      # Checks if sync connection is used
      def self.check_if_sync_client!(client)
        raise Syncano::BaseError.new('Operation available only for Sync client') unless client.is_a?(::Syncano::Clients::Sync)
      end

      # Checks if object uses sync connection
      def check_if_sync_client!
        self.class.check_if_sync_client!(client)
      end
    end
  end
end