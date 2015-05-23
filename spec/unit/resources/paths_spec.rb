require_relative '../../spec_helper'

describe ::Syncano::Resources::Paths do
  let(:koza) { double 'KozaClass' }

  context 'collections' do
    subject { described_class.instance.collections }

    before { subject.define '/kozas/{koza_name}/kiszkas/', koza }

    specify { expect(subject.match('/kozas/mykoza/kiszkas/')).to eq(koza) }
  end

  context 'members' do
    subject { described_class.instance.members }

    before { subject.define '/kozas/{koza_name}/', koza }

    xspecify { expect(subject.match('kozas/mykoza/')).to eq(koza) }
  end
end