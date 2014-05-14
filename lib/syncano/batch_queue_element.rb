class Syncano
  class BatchQueueElement

    def initialize(resource)
      super()
      self.resource = resource.dup
    end

    def method_missing(sym, *args, &block)
      self.method_name = 'batch_' + sym.to_s
      self.args = args
      self.block = block
      self
    end

    def perform!(batch_client)
      args.unshift(batch_client)
      resource.send(method_name, *args, &block)
    end

    private

    attr_accessor :resource, :method_name, :args, :block
  end
end