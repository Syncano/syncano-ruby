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

      def batch
        ::Syncano::BatchQueueElement.new(self)
      end

      # Wrapper for api "get" method
      # Returns all objects from Syncano
      # @return [Syncano::Response]
      def self.all(client, scope_parameters = {}, conditions = {})
        response = perform_all(client, scope_parameters, conditions)

        if response.status
          response.data.to_a.collect { |attributes| self.new(client, attributes.merge(scope_parameters)) }
        end
      end

      def self.count(client, scope_parameters = {}, conditions = {})
        perform_count(client, scope_parameters, conditions)
      end

      # Wrapper for api "get_one" method
      # Returns one object from Syncano
      # @param [Integer, Hash] key
      # @return [Syncano::Resource::Base]
      def self.find(client, key, scope_parameters = {}, conditions = {})
        response = perform_find(client, primary_key, key, scope_parameters, conditions)

        if response.status
          self.new(client, scope_parameters.merge(response.data))
        end
      end

      # Wrapper for api "new" method
      # Creates object in Syncano
      # @return [Syncano::Response]
      def self.create(client, attributes)
        response = perform_create(client, nil, attributes)

        if response.status
          self.new(client, map_to_scope_parameters(attributes).merge(response.data))
        end
      end

      def self.batch_create(batch_client, client, attributes)
        perform_create(client, batch_client, attributes)
      end

      # Wrapper for api "update" method
      # Updates object in Syncano
      # @param [Integer, Hash] key
      # @return [Syncano::Response]
      def update(attributes)
        response = perform_update(nil, attributes)

        if response.status
          response.data.delete('id')
          self.attributes = scope_parameters.merge(response.data)
          mark_as_saved!
        else
          self.errors << 'Something went wrong'
        end

        self
      end

      def batch_update(batch_client, attributes)
        perform_update(batch_client, attributes)
      end

      def save
        response = perform_save(nil)

        if new_record?
          self.id = response.id
          self.attributes = response.attributes
          self.errors = response.errors
          mark_as_saved! if errors.empty?
        end

        self
      end

      def batch_save(batch_client)
        perform_save(batch_client)
      end

      # Wrapper for api "delete" method
      # Destroys object in Syncano
      # @param [Integer, Hash] key
      # @return [Syncano::Response]
      def destroy
        response = perform_destroy(nil)

        self.destroyed = response.status
        self
      end

      def batch_destroy(batch_client)
        perform_destroy(batch_client)
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

      def self.perform_all(client, scope_parameters, conditions)
        check_class_method_existance!(:all)
        make_request(client, nil, :all, conditions.merge(scope_parameters))
      end

      def self.perform_count(client, scope_parameters, conditions)
        check_class_method_existance!(:count)
        all(client, scope_parameters, conditions).count
      end

      def self.perform_find(client, key_name, key, scope_parameters, conditions)
        check_class_method_existance!(:find)
        make_member_request(client, nil, :find, key_name, conditions.merge(scope_parameters.merge(key_name.to_sym => key)))
      end

      def self.perform_create(client, batch_client, attributes)
        check_class_method_existance!(:create)
        make_request(client, batch_client, :create, attributes_to_sync(attributes))
      end

      def perform_update(batch_client, attributes)
        check_instance_method_existance!(:update)
        self.class.make_member_request(client, batch_client, :update, self.class.primary_key, self.class.attributes_to_sync(attributes).merge(self.class.primary_key.to_sym => primary_key))
      end

      def perform_save(batch_client)
        check_instance_method_existance!(:save)

        if new_record?
          self.class.perform_create(client, batch_client, attributes)
        else
          perform_update(batch_client, attributes)
        end
      end

      def perform_destroy(batch_client)
        check_instance_method_existance!(:destroy)
        self.class.make_member_request(client, batch_client, :destroy, scope_parameters.merge({ self.class.primary_key.to_sym => primary_key }))
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
      # @param [String] method_name
      # @param [Hash] attributes for specific type of object
      # @return [Syncano::Response]
      def self.make_request(client, batch_client, method_name, attributes = {})
        if batch_client.present?
          client.make_batch_request(batch_client, api_resource, api_method(method_name), attributes)
        else
          client.make_request(api_resource, api_method(method_name), attributes)
        end
      end

      # Calls request to api for methods operating on a particular object
      # @param [Integer, Hash] key
      # @param [String] method_name
      # @param [Hash] attributes for specific type of object
      # @return [Syncano::Response]
      def self.make_member_request(client, batch_client, method_name, key, attributes = {})
        key_attributes = { "#{api_resource}_#{key}" => attributes[key].to_s }
        make_request(client, batch_client, method_name, attributes.merge(key_attributes))
      end

      class_attribute :syncano_model_name, :scope_parameters, :crud_class_methods, :crud_instance_methods, :primary_key

      self.syncano_model_name = nil
      self.scope_parameters = []
      self.crud_class_methods = [:all, :find, :new, :create, :count]
      self.crud_instance_methods = [:save, :update, :destroy]
      self.primary_key = :id

      def self.map_to_scope_parameters(attributes)
        Hash[scope_parameters.map{ |sym| [sym, attributes[sym]]}]
      end

      def scope_parameters
        self.class.map_to_scope_parameters(attributes)
      end

      def primary_key
        @saved_attributes[self.class.primary_key]
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