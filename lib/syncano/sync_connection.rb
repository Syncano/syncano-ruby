class Syncano
  class SyncConnection < EventMachine::Connection

    attr_accessor :client, :callbacks, :callbacks_queue, :responses, :responses_queue

    def initialize
      super

      self.callbacks = ::ActiveSupport::HashWithIndifferentAccess.new
      self.callbacks_queue = []

      self.responses = ::ActiveSupport::HashWithIndifferentAccess.new
      self.responses_queue = []

      self.client = ::Syncano::Clients::Sync.instance
    end

    def connection_completed
      start_tls
    end

    def ssl_handshake_completed
      auth_data = {
        api_key: SYNCANO_API_KEY,
        instance: SYNCANO_INSTANCE_NAME
      }

      client.connection = self

      send_data "#{auth_data.to_json}\n"
    end

    def receive_data(data)
      begin
        data = ::ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(data))
        packet = ::Syncano::Packets::Base.instantize_packet(data)

        if packet.notification?
          notification = ::Syncano::Resources::Notifications::Base.instantize_notification(client, packet)

          callbacks_queue.each do |callback_name|
            callbacks[callback_name].call(notification)
          end
        elsif packet.call_response?
          queue_response(packet)
        end
      rescue Exception => e
        p e.inspect
        p e.backtrace
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

    def get_response(message_id)
      responses.delete(message_id)
    end

    private

    def queue_response(packet)
      prune_responses_queue
      message_id = packet.message_id.to_i
      responses[message_id] = packet
      responses_queue << message_id
    end

    def prune_responses_queue
      while !responses_queue.empty?
        message_id = responses_queue.first

        if responses_queue[message_id].nil? || Time.now - responses[message_id].timestamp.to_time > 2.minutes
          responses_queue.shift
          responses.delete(message_id)
        else
          break
        end
      end
    end
  end
end