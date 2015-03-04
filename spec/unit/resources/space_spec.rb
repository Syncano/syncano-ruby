require_relative '../../spec_helper'

describe Syncano::Resources::Space do
  let(:resource) { double('resource', primary_key: 123) }
  let(:query_builder) { spy('query_builder') }

  it 'should pass the query to the query builder with a default direction' do
    described_class.new(resource, query_builder).all

    expect(query_builder).to have_received(:all).with(last_pk: 123, direction: 1)
  end

  it 'should translate order desc to query builder direction' do
    described_class.new(resource, query_builder, direction: :prev).all

    expect(query_builder).to have_received(:all).with(last_pk: 123, direction: 0)
  end

  it 'should translate order asc to query builder direction' do
    described_class.new(resource, query_builder, direction: :next).all

    expect(query_builder).to have_received(:all).with(last_pk: 123, direction: 1)
  end

  it 'should raise an error on invalid options' do
    expect { described_class.new(resource, query_builder, direction: :koza).all }.to raise_error(Syncano::RuntimeError)
  end
end