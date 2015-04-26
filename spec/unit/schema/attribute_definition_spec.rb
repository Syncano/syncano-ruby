require_relative  '../../spec_helper'

describe Syncano::Schema::AttributeDefinition do
  let(:name) { 'Example' }
  let(:raw_definition) { {} }

  subject { described_class.new name, raw_definition }

  specify { expect(subject.name).to eq(name) }
end
