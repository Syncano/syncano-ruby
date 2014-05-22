class Syncano
  module Resources
    # Module used as a scope for classes representing notifications
    module Notifications
      # Base notification class used for inheritance
      class Base < Syncano::Resources::Base
        attr_accessor :id, :source, :target, :data

        # Constructor for Syncano::Notifications::Base object
        # @param [Syncano::Clients::Base] client
        # @param [Hash] attributes
        def initialize(client, attributes)
          if attributes.is_a?(::Syncano::Packets::Base)
            super(client, {})
            self.attributes = { source: attributes.source, target: attributes.target, data: attributes.data }
          else
            super(client, attributes)
          end
        end

        # Proxy method for creating instance of proper subclass
        # @param [Syncano::Clients::Base] client
        # @param [Syncano::Packets::Base] packet
        # @return [Syncano::Notifications::Base]
        def self.instantize_notification(client, packet)
          if packet.message?
            ::Syncano::Resources::Notifications::Message.new(client, packet)
          else
            mapping = {
              new: ::Syncano::Resources::Notifications::Create,
              change: ::Syncano::Resources::Notifications::Update,
              delete: ::Syncano::Resources::Notifications::Destroy
            }

            mapping[packet.type.to_sym].new(client, packet)
          end
        end

        # Wrapper for api "get" method
        # Returns all objects from Syncano
        # @param [Syncano::Clients::Base] client
        # @param [Hash] scope_parameters
        # @param [Hash] conditions
        # @return [Array] which contains Syncano::Resources::Base objects
        def self.all(client, scope_parameters = {}, conditions = {})
          mapping = {
              new: ::Syncano::Resources::Notifications::Create,
              change: ::Syncano::Resources::Notifications::Update,
              delete: ::Syncano::Resources::Notifications::Destroy,
              message: ::Syncano::Resources::Notifications::Message
          }

          response = perform_all(client, scope_parameters, conditions)
          response.data.to_a.collect do |attributes|
            type = attributes.delete(:type)
            mapping[type.to_sym].new(client, attributes.merge(scope_parameters))
          end
        end

        # Wrapper for api "send" method
        # Creates object in Syncano
        # @param [Syncano::Clients::Base] client
        # @param [Hash] attributes
        # @return [Syncano::Resources::Base]
        def self.create(client, attributes)
          response = perform_create(client, nil, attributes)
          ::Syncano::Resources::Notifications::Message.new(client, map_to_scope_parameters(attributes))
        end

        private

        self.syncano_model_name = 'notification'
        self.crud_class_methods = [:all, :new, :create]
        self.crud_instance_methods = [:save]

        # Executes proper all request
        # @param [Syncano::Clients::Base] client
        # @param [Hash] scope_parameters
        # @param [Hash] conditions
        # @return [Syncano::Response]
        def self.perform_all(client, scope_parameters, conditions)
          make_request(client, nil, :get_history, conditions.merge(scope_parameters), :history)
        end

        # Executes proper create request
        # @param [Syncano::Clients::Base] client
        # @param [Jimson::BatchClient] batch_client
        # @param [Hash] attributes
        # @return [Syncano::Response]
        def self.perform_create(client, batch_client, attributes)
          make_request(client, batch_client, :send, attributes_to_sync(attributes))
        end

        # Executes proper save request
        # @param [Jimson::BatchClient] batch_client
        # @return [Syncano::Response]
        def perform_save(batch_client)
          if new_record?
            self.class.perform_create(client, batch_client, attributes)
          end
        end
      end
    end
  end
end