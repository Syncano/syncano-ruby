require_relative '../spec_helper'


describe Syncano::QueryBuilder do
  let(:connection) { double('connection') }
  let(:resource_class) { double('resource_class') }
  let(:scope_parameters) { { foo: :bar } }

  subject { described_class.new(connection, resource_class, scope_parameters) }

  describe '.initialize' do
    it { expect(subject.instance_eval{ connection }).to eq(connection) }
    it { expect(subject.instance_eval{ resource_class }).to eq(resource_class) }
    it { expect(subject.instance_eval{ scope_parameters }).to eq(scope_parameters) }
  end

  describe '.all' do
    specify do
      expect(resource_class).to receive(:all).with(connection, scope_parameters, {})
      subject.all
    end
  end

  describe '.first' do
    specify do
      expect(resource_class).to receive(:first).with(connection, scope_parameters)
      subject.first
    end
  end

  describe '.last' do
    specify do
      expect(resource_class).to receive(:last).with(connection, scope_parameters)
      subject.last
    end
  end

  describe '.find' do
    specify do
      key = 100
      expect(resource_class).to receive(:find).with(connection, scope_parameters, key)
      subject.find(key)
    end
  end

  describe '.new' do
    specify do
      attributes = { bar: :foo }
      expect(resource_class).to receive(:new).with(connection, scope_parameters, attributes)
      subject.new(attributes)
    end
  end

  describe '.create' do
    specify do
      attributes = { bar: :foo }
      expect(resource_class).to receive(:create).with(connection, scope_parameters, attributes)
      subject.create(attributes)
    end
  end

  describe '.space' do
    let(:options) { double }
    let(:resource) { double }
    let(:space) { double }

    before do
      expect(Syncano::Resources::Space).to receive(:new).with(resource, subject, options).and_return(space)
    end

    it 'should return a Space object with passed options' do
      expect(subject.space(resource, options)).to eq(space)
    end
  end
end