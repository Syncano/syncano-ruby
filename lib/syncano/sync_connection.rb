class Syncano
  # Represents connection with Sync Server
  class SyncConnection < EventMachine::Connection
    attr_accessor :client, :callbacks, :callbacks_queue, :responses, :responses_queue

    # Constructor for Syncano::SyncConnection object
    def initialize
      super

      self.callbacks = ::ActiveSupport::HashWithIndifferentAccess.new
      self.callbacks_queue = []

      self.responses = ::ActiveSupport::HashWithIndifferentAccess.new
      self.responses_queue = []

      self.client = ::Syncano::Clients::Sync.instance
    end

    # Eventmachine callback invoked after completing connection
    def connection_completed
      start_tls
    end

    # Eventmachine callback invoked completing ssl handshake
    def ssl_handshake_completed
      auth_data = {
        api_key: client.api_key,
        instance: client.instance_name
      }

      client.connection = self

      send_data "#{auth_data.to_json}\n"
    end

    # Eventmachine callback invoked after receiving data from socket
    # Data are parsed here and processed by callbacks chain
    def receive_data(data)
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
    end

    # Appends callback method to the end of callbacks chain
    # @param [Symbol, String] callback_name
    # @param [Block] callback
    def append_callback(callback_name, callback)
      callbacks[callback_name] = callback
      callbacks_queue << callback_name
    end

    # Prepends callback method to the beginning of callbacks chain
    # @param [Symbol, String] callback_name
    # @param [Block] callback
    def prepend_callback(callback_name, callback)
      callbacks[callback_name] = callback
      callbacks_queue.unshift(callback_name)
    end

    # Removes callback from callbacks chain
    # @param [Symbol, String] callback_name
    def remove_callback(callback_name)
      callbacks.delete(callback_name)
      callbacks_queue.delete(callback_name)
    end

    # Gets call response packet from the responses queue
    # @param [Integer, String] message_id
    # @return [Syncano::Packets::CallResponse]
    def get_response(message_id)
      responses.delete(message_id)
    end

    private

    # Adds call response packet to the responses queue
    # @param [Syncano::Packets::CallResponse] packet
    def queue_response(packet)
      prune_responses_queue
      message_id = packet.message_id.to_i
      responses[message_id] = packet
      responses_queue << message_id
    end

    # Removes old call response packets from the responses queue
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