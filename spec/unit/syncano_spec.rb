require_relative "../spec_helper"


describe Syncano do
  describe "#connect" do
    let(:options) { {} }

    before do
      expect_any_instance_of(Syncano::Connection).
        to receive(:authenticated?).and_return(false)
      expect_any_instance_of(Syncano::Connection).
        to receive(:authenticate).with(options)
    end

    specify { expect(Syncano.connect(options)).to be_kind_of(Syncano::API) }
  end
end

