require_relative  '../../spec_helper'

describe Syncano::Schema::ResourceDefinition do
  let(:attribute) { double 'attribute' }
  let(:definition) do
    described_class.new(name, attributes: { 'koza' => raw_attribute },
                        associations: {
                          'links' => [{ 'name' => 'koza', 'type' => 'detail' }]
                        })
  end
  let(:name) { 'Kiszka' }
  let(:raw_attribute) { double 'raw attribute' }

  before do
    expect(Syncano::Schema::AttributeDefinition).to receive(:new).with('koza', raw_attribute).and_return(attribute)
  end

  specify { expect(definition.attributes).to eq([attribute]) }

  specify { expect(definition.name).to eq(name) }

  it 'should delete colliding links' do
    expect(definition[:associations]['links']).to be_empty
  end
end