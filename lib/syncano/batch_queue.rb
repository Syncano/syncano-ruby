class Syncano
  class BatchQueue
    REQUEST_LIMIT = 10
    attr_reader :responses

    # Constructor for Syncano::BatchQueue
    # @param [Syncano::Client] client
    def initialize(client)
      super()
      self.client = client
      self.queue = []
      self.responses = []
    end

    # Adds element to the queue and prune it if is full
    # @param [Syncano::BatchQueueElement] element
    def add(element)
      self.queue << element
      prune! while full?
    end

    # Alias for "add" method
    # @param [Syncano::BatchQueueElement] element
    def <<(element)
      add(element)
    end

    # Counts elements in the queue
    # @return [Integer]
    def count
      queue.count
    end

    # Checks if queue is full
    # @return [TrueClass, FalseClass]
    def full?
      count >= REQUEST_LIMIT
    end

    # Prunes queue and makes batch request to the api
    # @return [Array] collection of Syncano::Response objects
    def prune!
      part = self.queue.slice!(0, 10)
      ::Jimson::Client.batch(client) do |batch_client|
        part.each do |element|
          element.perform!(batch_client)
        end
      end.collect { |response| self.responses << response }
    end

    protected

    attr_accessor :client, :queue
    attr_writer :responses
  end
end