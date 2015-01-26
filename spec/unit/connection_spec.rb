require_relative '../spec_helper'

describe Syncano::Connection do
  context 'api_key set' do
    subject { described_class.new api_key: 'fafarafa' }

    it { should be_authenticated }
  end

  describe '#authenticate' do
    context 'successful' do
      subject do
        described_class.new email: 'kiszka@koza.com',
                            password: 'kiszonka'
      end

      it 'should get an API key' do
        expect { subject.authenticate }.to change { subject.authenticated? }
      end
    end

    context 'failed' do
      subject do
        described_class.new email: 'kiszka@koza.com',
                            password: 'as'
      end

      it 'should raise an exception' do
        expect { subject.authenticate }.to raise_error(Syncano::ClientError)
      end
    end
  end
end
