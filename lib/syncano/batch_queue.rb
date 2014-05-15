class Syncano
  class BatchQueue
    REQUEST_LIMIT = 10

    attr_reader :responses

    def initialize(client)
      super()
      self.client = client
      self.queue = []
      self.responses = []
    end

    def add(element)
      self.queue << element
      prune! while full?
    end

    def <<(element)
      add(element)
    end

    def count
      queue.count
    end

    def full?
      count >= REQUEST_LIMIT
    end

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