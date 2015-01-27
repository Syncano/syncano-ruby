require 'syncano'

describe Syncano::API do
  let(:connection) { double }

  specify { expect(described_class.new(connection)).to respond_to(:models) }
end
