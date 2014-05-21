class Syncano
  module Resources
  end

  class SyncClient
    include Singleton

    attr_accessor :instance_name, :api_key, :connection

    def initialize(instance_name, api_key)
      super()

      self.instance_name = instance_name
      self.api_key = api_key
      self.connection = nil
    end

    def self.instance(instance_name = nil, api_key = nil)
      return @singleton__instance__ if @singleton__instance__
      @singleton__mutex__.synchronize {
        return @singleton__instance__ if @singleton__instance__
        @singleton__instance__ = new(instance_name, api_key)
      }
      @singleton__instance__
    end

    def connect
      if connection.blank?
        hostname = 'api.syncano.com'
        port = 8200

        Thread.new do
          EM.run do
            EM.connect hostname, port, Syncano::SyncConnection
          end
        end

        timeout = 10

        while connection.blank? && timeout > 0
          timeout -= 1
          sleep 1
        end

        raise 'Connection timeout' if timeout == 0
      end
    end

    def disconnect
      EM.stop
      self.connection = nil
    end

    def reconnect
      disconnect
      connect
    end

    def subscribe_project(project_id)
      make_request('subscription', 'subscribe_project', { project_id: project_id })
    end

    def unsubscribe_project(project_id)
      make_request('subscription', 'unsubscribe_project', { project_id: project_id })
    end

    def subscribe_collection(project_id, collection_id)
      make_request('subscription', 'subscribe_collection', { project_id: project_id, collection_id: collection_id })
    end

    def unsubscribe_collection(project_id, collection_id)
      make_request('subscription', 'unsubscribe_collection', { project_id: project_id, collection_id: collection_id })
    end

    def append_callback(callback_name, &callback)
      connection.append_callback(callback_name, callback)
    end

    def prepend_callback(callback_name, &callback)
      connection.prepend_callback(callback_name, callback)
    end

    def remove_callback(callback_name)
      connection.remove_callback(callback_name)
    end

    def send_notification(data)
      make_request('notification', 'send', data)
    end

    def admins
      ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Admin)
    end

    def projects
      ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Project)
    end

    def make_request(resource_name, method_name, params = {})
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

      response = self.class.parse_response(resource_name, response_packet.to_response)
      response.errors.present? ? raise(Syncano::ApiError.new(response.errors)) : response
    end

    private

    def self.parse_response(resource_name, raw_response)
      status = raw_response.nil? || raw_response['result'] != 'NOK'
      if raw_response.nil?
        data = nil
      elsif raw_response[resource_name].present?
        data = raw_response[resource_name]
      else
        data = raw_response['count']
      end
      errors = status ? [] : raw_response['error']

      ::Syncano::Response.new(status, data, errors)
    end
  end
end