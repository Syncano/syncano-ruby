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

        if timeout == 0
          raise 'Connection timeout'
        end
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

    def make_request(resource_name, method_name, params = {})
      packet = ::Syncano::Packets::Call.new(resource_name: resource_name, method_name: method_name, data: params)
      connection.send_data("#{packet.to_json}\n")
    end
  end
end