require_relative '../spec_helper'

describe Syncano::PathToResource do
  subject { described_class.instance }

  let(:koza) { double 'KozaClass' }

  context 'defining path to resource map' do
    it 'should allow find ' do
      subject.collection['/kozas/{koza_name}/'] = koza
      expect(subject.collection['/kozas/mykoza/']).to eq(koza)
    end
  end
end