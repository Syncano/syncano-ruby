class Syncano
  # Class representing objects batch requests queued for processing
  class BatchQueueElement
    # Constructor for Syncano::BatchQueueElement
    # @param [Syncano::QueryBuilder, Syncano::Resources::Base] resource
    def initialize(resource)
      super()
      self.resource = resource.dup
    end

    # Overwritten method_missing used for preparing execution of proper batch method on the resource object
    # @param [Symbol] sym
    # @param [Array] args
    # @param [Proc] block
    # @return [Syncano::BatchQueueElement]
    def method_missing(sym, *args, &block)
      self.method_name = 'batch_' + sym.to_s
      self.args = args
      self.block = block
      self
    end

    # Executes batch method on the resource object
    def perform!(batch_client)
      args.unshift(batch_client)
      resource.send(method_name, *args, &block)
    end

    private

    attr_accessor :resource, :method_name, :args, :block
  end
end