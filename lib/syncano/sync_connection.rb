class Syncano
  class SyncConnection < EventMachine::Connection

    attr_accessor :callbacks, :callbacks_queue

    def initialize
      super
      self.callbacks = ActiveSupport::HashWithIndifferentAccess.new
      self.callbacks_queue = []
    end

    def connection_completed
      start_tls
    end

    def ssl_handshake_completed
      auth_data = {
        api_key: SYNCANO_API_KEY,
        instance: SYNCANO_INSTANCE_NAME
      }

      Syncano::SyncClient.instance.connection = self
      send_data "#{auth_data.to_json}\n"
    end

    def receive_data(data)
      notification = JSON.parse(data)

      callbacks_queue.each do |callback_name|
        callbacks[callback_name].call(notification)
      end
    end

    def append_callback(callback_name, callback)
      callbacks[callback_name] = callback
      callbacks_queue << callback_name
    end

    def prepend_callback(callback_name, callback)
      callbacks[callback_name] = callback
      callbacks_queue.unshift(callback_name)
    end

    def remove_callback(callback_name)
      callbacks.delete(callback_name)
      callbacks_queue.delete(callback_name)
    end
  end
end