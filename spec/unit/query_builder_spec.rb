require_relative '../spec_helper'


describe Syncano::QueryBuilder do
  let(:connection) { double('connection') }
  let(:resource_class) { double('resource_class') }
  let(:scope_parameters) { { foo: :bar } }

  describe '.initialize' do
    subject { described_class.new(connection, resource_class, scope_parameters) }

    it { subject.instance_eval{ connection }.should eql?(connection) }
    it { subject.instance_eval{ resource_class }.should eql?(resource_class) }
    it { subject.instance_eval{ scope_parameters }.should eql?(scope_parameters) }
  end

  describe '.all' do
    subject { described_class.new(connection, resource_class, scope_parameters) }

    it do
      expect(resource_class).to receive(:all).with(connection, scope_parameters)
      subject.all
    end
  end

  describe '.first' do
    subject { described_class.new(connection, resource_class, scope_parameters) }

    it do
      expect(resource_class).to receive(:first).with(connection, scope_parameters)
      subject.first
    end
  end

  describe '.last' do
    subject { described_class.new(connection, resource_class, scope_parameters) }

    it do
      expect(resource_class).to receive(:last).with(connection, scope_parameters)
      subject.last
    end
  end

  describe '.find' do
    subject { described_class.new(connection, resource_class, scope_parameters) }

    it do
      key = 100
      expect(resource_class).to receive(:find).with(connection, scope_parameters, key)
      subject.find(key)
    end
  end

  describe '.new' do
    subject { described_class.new(connection, resource_class, scope_parameters) }

    it do
      attributes = { bar: :foo }
      expect(resource_class).to receive(:new).with(connection, scope_parameters, attributes)
      subject.new(attributes)
    end
  end

  describe '.create' do
    subject { described_class.new(connection, resource_class, scope_parameters) }

    it do
      attributes = { bar: :foo }
      expect(resource_class).to receive(:create).with(connection, scope_parameters, attributes)
      subject.create(attributes)
    end
  end
end