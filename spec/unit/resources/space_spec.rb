require_relative '../../spec_helper'

describe Syncano::Resources::Space do
  let(:resource) { double('resource', primary_key: 123) }
  let(:query_builder) { spy('query_builder') }

  it 'should do something' do
    described_class.new(resource, query_builder).all

    expect(query_builder).to have_received(:all).with(last_pk: 123, direction: 1)
  end
end