class Syncano
  module Resources
    class Base
      attr_accessor :client

      def initialize(client)
        super()
        self.client = client
      end

      def find_all
        make_request(__method__)
      end

      def find(id)
        make_member_request(id, __method__)
      end

      def create(attributes)
        make_request(__method__, attributes)
      end

      def update(id, attributes)
        make_member_request(id, __method__, attributes)
      end

      def destroy(id)
        make_member_request(id, __method__)
      end

      private

      def api_resource
        self.class.to_s.demodulize.downcase
      end

      def make_request(method_name, attributes = {})
        client.make_request(api_resource, api_method(method_name), attributes)
      end

      def make_member_request(id, method_name, attributes = {})
        attributes.merge!({ "#{api_resource}_id" => id.to_s })
        make_request(method_name, attributes)
      end

      def api_method(method_name)
        mapping = { find_all: :get, find: :get_one, create: :new, update: :update, destroy: :delete }
        mapping.keys.include?(method_name.to_sym) ? mapping[method_name.to_sym] : method_name
      end
    end
  end
end