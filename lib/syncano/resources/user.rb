class Syncano
  module Resources
    class User < ::Syncano::Resources::Base
      # Wrapper for api "count" method
      # @param [Syncano::Client] client
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Integer]
      def self.count(client, scope_parameters = {}, conditions = {})
        response = perform_count(client, scope_parameters, conditions)
        response.data if response.status
      end

      private

      self.scope_parameters = [:project_id, :collection_id]

      # Prepares hash with attributes used in synchronization with Syncano
      # @return [Hash]
      def self.attributes_to_sync(attributes)
        attributes = attributes.dup

        if attributes.keys.map(&:to_sym).include?(:avatar)
          if attributes[:avatar].blank?
            attributes[:avatar] = ''
          elsif attributes[:avatar].is_a?(String)
            attributes[:avatar] = Base64.encode64(File.read(attributes[:avatar]))
          else
            attributes.delete(:image)
          end
        end

        attributes
      end

      # Executes proper count request
      # @param [Syncano::Client] client
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Syncano::Response]
      def self.perform_count(client, scope_parameters, conditions)
        make_request(client, nil, :count, conditions.merge(scope_parameters))
      end
    end
  end
end