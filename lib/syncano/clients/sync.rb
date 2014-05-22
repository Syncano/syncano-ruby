class Syncano
  module Clients
    # Client used for communication with the Sync Server
    class Sync < Syncano::Clients::Base
      include Singleton

      attr_accessor :connection

      # Constructor for Syncano::Clients::Sync object
      # @param [String] instance_name
      # @param [String] api_key
      def initialize(instance_name, api_key)
        super(instance_name, api_key)
        self.connection = nil
      end

      # Getter for Singleton instance
      # @param [String] instance_name
      # @param [String] api_key
      # @return [Syncano::Clients::Base]
      def self.instance(instance_name = nil, api_key = nil)
        unless @singleton__instance__
          @singleton__mutex__.synchronize do
            return @singleton__instance__ if @singleton__instance__
            @singleton__instance__ = new(instance_name, api_key)
          end
        end
        @singleton__instance__
      end

      # Connects with the Sync api
      def connect
        if connection.blank?
          hostname = 'api.syncano.com'
          port = 8200

          Thread.new do
            EM.run do
              EM.connect(hostname, port, Syncano::SyncConnection)
            end
          end

          timeout = 30

          while connection.blank? && timeout > 0
            timeout -= 1
            sleep 1
          end

          raise ::Syncano::ConnectionError.new('Connection timeout') unless timeout > 0
        end
      end

      # Disconnects with the Sync api
      def disconnect
        EM.stop
        self.connection = nil
      end

      # Reconnects with the Sync api
      def reconnect
        disconnect
        connect
      end

      # Returns query builder for Syncano::Resources::Subscription objects
      # @return [Syncano::QueryBuilder]
      def subscriptions
        ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Subscription)
      end

      # Returns query builder for Syncano::Resources::Notifications::Base objects
      # @return [Syncano::QueryBuilder]
      def notifications
        ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Notifications::Base)
      end

      # Appends callback for processing notifications to the end of callbacks queue
      # @return [Syncano::QueryBuilder]
      def append_callback(callback_name, &callback)
        connection.append_callback(callback_name, callback)
      end

      # Prepends callback for processing notifications to the beginning of callbacks queue
      # @return [Syncano::QueryBuilder]
      def prepend_callback(callback_name, &callback)
        connection.prepend_callback(callback_name, callback)
      end

      # Removes callback from the callbacks queue
      # @return [Syncano::QueryBuilder]
      def remove_callback(callback_name)
        connection.remove_callback(callback_name)
      end

      # Performs request to Syncano api
      # This should be overwritten in inherited classes
      # @param [String] resource_name
      # @param [String] method_name
      # @param [Hash] params additional params sent in the request
      # @param [String] response_key for cases when response from api is incompatible with the convention
      # @return [Syncano::Response]
      def make_request(resource_name, method_name, params = {}, response_key = nil)
        response_key ||= resource_name

        packet = ::Syncano::Packets::Call.new(resource_name: resource_name, method_name: method_name, data: params)
        connection.send_data("#{packet.to_json}\n")

        response_packet = nil
        timer = 600

        while timer > 0
          response_packet = connection.get_response(packet.message_id)
          if response_packet.nil?
            timer -= 1
            sleep 1.0 / 10.0
          else
            break
          end
        end

        response = self.class.parse_response(response_key, response_packet.to_response)
        response.errors.present? ? raise(Syncano::ApiError.new(response.errors)) : response
      end
    end
  end
end