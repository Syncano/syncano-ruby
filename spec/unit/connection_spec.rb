require 'syncano'

describe Syncano::Connection do
  context 'api_key set' do
    subject { described_class.new api_key: 'fafarafa' }

    it { should be_authenticated }
  end

  describe '#authenticate' do
    subject do
      described_class.new email: 'kiszka@koza.com',
                          password: 'kiszonka'
    end
  end
end
