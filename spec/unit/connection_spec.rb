require_relative '../spec_helper'
require 'json'

describe Syncano::Connection do
  context 'api_key' do
    specify { expect(described_class.new(api_key: 'fafarafa')).to be_authenticated }
    specify { expect(described_class.new).to_not be_authenticated }
  end

  describe '#authenticate' do
    subject { described_class.new email: email, password: password }

    let(:authenticate_uri) { endpoint_uri('account/auth/') }
    let(:email) { 'kiszka@koza.com' }
    let(:password) { 'kiszonka' }
    let(:success_status) { 200 }
    let(:unauthorized_status) { 401 }

    context 'successful' do
      before do
        expect(subject).to receive(:request).
          with(:post, described_class::AUTH_PATH, email: email, password: password).
          and_return('account_key' => 'kEy')
      end

      specify do
        expect { subject.authenticate }.to change { subject.authenticated? }
      end
    end

    context 'failed' do
      before do
        expect(subject).to receive(:request).and_raise('auth failed')

      end

      specify do
        expect { subject.authenticate }.to raise_error('auth failed')
      end
    end
  end

  describe '#request' do
    let(:headers) { { 'X-Api-Key'=>'87a7da987da98sd7a98', 'User-Agent' => "Syncano Ruby Gem #{Syncano::VERSION}" } }
    let(:api_key) { '87a7da987da98sd7a98' }
    let(:connection_params) { { api_key: api_key, user_key: 'Us3rK3y' } }
    let(:raw_response) { { body: 'koza' } }
    let(:handled_response) { double :handled_response }

    subject { described_class.new(connection_params) }

    context 'with supported method' do
      before do
        stub_request(:get, endpoint_uri('user/method/')).
          with(headers: headers).to_return(raw_response)

        expect(Syncano::Response).
          to receive(:handle) { |raw_response| expect(raw_response.body).to eq('koza') }.
               and_return(handled_response)
      end

      specify do
        expect(subject.request(:get, 'user/method/')).to eq(handled_response)
      end
    end

    context 'with unsupported method' do
      specify do
        expect { subject.request :koza, 'fafarafa' }.
          to raise_error(RuntimeError, 'Unsupported method "koza"')
      end
    end
  end
end
