require_relative  '../../spec_helper'

describe Syncano::Schema::ResourceDefinition do
  let(:raw_attribute) { double 'raw attribute' }
  let(:attribute) { double 'attribute' }

  before do
    expect(Syncano::Schema::AttributeDefinition).to receive(:new).with('koza', raw_attribute).and_return(attribute)
  end

  it 'should create AttributeDefinition objects' do
    expect(described_class.new(attributes: { 'koza' => raw_attribute }).attributes).to eq([attribute])
  end
end