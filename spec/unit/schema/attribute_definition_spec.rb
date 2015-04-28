require_relative  '../../spec_helper'

describe Syncano::Schema::AttributeDefinition do
  let(:name) { 'example' }
  let(:raw_definition) { {} }

  subject { described_class.new name, raw_definition }

  specify { expect(subject.name).to eq(name) }

  context 'when name is "class"' do
    let(:name) { 'class' }

    it 'should be named associated_class to avoid method name collision' do
      expect(subject.name).to eq('associated_class')
    end
  end
end
