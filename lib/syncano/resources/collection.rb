class Syncano
  module Resources
    class Collection < ::Syncano::Resources::Base
      # Constructor for Collection resource
      # @param [Syncano::Client] client
      # @param [Integer, String] project_id
      def initialize(client, project_id)
        super(client, { project_id: project_id })
      end

      # Wrapper for api "activate" method
      # @param [Integer, Hash] key
      # @return [Syncano::Response]
      def activate(key, force = false)
        make_member_request(key, __method__, force: force)
      end

      # Wrapper for api "deactivate" method
      # @param [Integer, Hash] key
      # @return [Syncano::Response]
      def deactivate(key)
        make_member_request(key, __method__)
      end

      # Wrapper for api "add_tag" method
      # @param [Integer, Hash] key
      # @param [String, Array] tags
      # @param [Float] weight
      # @param [Boolean] remove_other
      # @return [Syncano::Response]
      def add_tag(key, tags, weight = 1, remove_other = false)
        attributes = { tags: tags, weight: weight, remove_other: remove_other }
        make_member_request(key, __method__, attributes)
      end

      # Wrapper for api "delete_tag" method
      # @param [Integer, Hash] key
      # @param [String, Array] tags
      # @return [Syncano::Response]
      def delete_tag(key, tags)
        attributes = { tags: tags }
        make_member_request(key, __method__, attributes)
      end
    end
  end
end