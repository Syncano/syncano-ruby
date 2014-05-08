class Syncano
  module Resources
    class Base
      attr_accessor :client, :attributes

      # Constructor for base resource
      # @param [Syncano::Client] client
      # @param [Hash] attributes used in making requests to api (ie. parent id)
      def initialize(client, attributes = {})
        super()
        self.client = client
        self.attributes = attributes
      end

      # Wrapper for api "get" method
      # Returns all objects from Syncano
      # @return [Syncano::Response]
      def all
        make_request(__method__)
      end

      # Wrapper for api "get_one" method
      # Returns one object from Syncano
      # @param [Integer, Hash] key
      # @return [Syncano::Response]
      def find(key)
        make_member_request(key, __method__)
      end

      # Wrapper for api "new" method
      # Creates object in Syncano
      # @return [Syncano::Response]
      def create(attributes)
        make_request(__method__, attributes)
      end

      # Wrapper for api "update" method
      # Updates object in Syncano
      # @param [Integer, Hash] key
      # @return [Syncano::Response]
      def update(key, attributes)
        make_member_request(key, __method__, attributes)
      end

      # Wrapper for api "delete" method
      # Destroys object in Syncano
      # @param [Integer, Hash] key
      # @return [Syncano::Response]
      def destroy(key)
        make_member_request(key, __method__)
      end

      private

      # Converts resource class name to corresponding Syncano resource name
      # @return [String]
      def api_resource
        self.class.to_s.split('::').last.downcase
      end

      # Converts Syncano gem method to corresponding Syncano api method
      # @param [String] method_name
      # @return [String]
      def api_method(method_name)
        mapping = { all: :get, find: :get_one, create: :new, update: :update, destroy: :delete }
        mapping.keys.include?(method_name.to_sym) ? mapping[method_name.to_sym] : method_name
      end

      # Calls request to api through client object
      # @param [String] method_name
      # @param [Hash] attributes for specific type of object
      # @return [Syncano::Response]
      def make_request(method_name, attributes = {})
        client.make_request(api_resource, api_method(method_name), attributes.merge(self.attributes))
      end

      # Calls request to api for methods operating on a particular object
      # @param [Integer, Hash] key
      # @param [String] method_name
      # @param [Hash] attributes for specific type of object
      # @return [Syncano::Response]
      def make_member_request(key, method_name, attributes = {})
        key_type = 'id'

        if key.is_a?(Hash)
          if key.keys.include?(:key)
            key_type = 'key'
            key = key[:key]
          else
            key = key[:id]
          end
        end

        make_request(method_name, attributes.merge({ "#{api_resource}_#{key_type}" => key.to_s }))
      end
    end
  end
end