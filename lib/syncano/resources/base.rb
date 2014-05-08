class Syncano
  module Resources
    class Base
      attr_accessor :client

      # Constructor for base resource
      # @param [Syncano::Client] client
      def initialize(client)
        super()
        self.client = client
      end

      # Wrapper for api "get" method
      # Returns all objects from Syncano
      # @return [Syncano::Response]
      def all
        make_request(__method__)
      end

      # Wrapper for api "get_one" method
      # Returns one object from Syncano
      # @param [Integer, String] id
      # @return [Syncano::Response]
      def find(id)
        make_member_request(id, __method__)
      end

      # Wrapper for api "new" method
      # Creates object in Syncano
      # @return [Syncano::Response]
      def create(attributes)
        make_request(__method__, attributes)
      end

      # Wrapper for api "update" method
      # Updates object in Syncano
      # @param [Integer, String] id
      # @return [Syncano::Response]
      def update(id, attributes)
        make_member_request(id, __method__, attributes)
      end

      # Wrapper for api "delete" method
      # Destroys object in Syncano
      # @param [Integer, String] id
      # @return [Syncano::Response]
      def destroy(id)
        make_member_request(id, __method__)
      end

      private

      # Converts resource class name to corresponding Syncano resource name
      # @return [String]
      def api_resource
        self.class.to_s.demodulize.downcase
      end

      # Converts Syncano gem method to corresponding Syncano api method
      # @param [String] method_name
      # @return [String]
      def api_method(method_name)
        mapping = { find_all: :get, find: :get_one, create: :new, update: :update, destroy: :delete }
        mapping.keys.include?(method_name.to_sym) ? mapping[method_name.to_sym] : method_name
      end

      # Calls request to api through client object
      # @param [String] method_name
      # @param [Hash] attributes for specific type of object
      # @return [Syncano::Response]
      def make_request(method_name, attributes = {})
        client.make_request(api_resource, api_method(method_name), attributes)
      end

      # Calls request to api for methods operating on a particular object
      # @param [Integer] id
      # @param [String] method_name
      # @param [Hash] attributes for specific type of object
      # @return [Syncano::Response]
      def make_member_request(id, method_name, attributes = {})
        attributes.merge!({ "#{api_resource}_id" => id.to_s })
        make_request(method_name, attributes)
      end
    end
  end
end