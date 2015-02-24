require_relative '../spec_helper'
require 'json'

describe Syncano::Connection do
  context 'api_key' do
    specify { expect(described_class.new(api_key: 'fafarafa')).to be_authenticated }
    specify { expect(described_class.new).to_not be_authenticated }
  end

  describe '#request' do
    let(:api_key) { '87a7da987da98sd7a98' }

    subject { described_class.new(api_key: api_key) }

    context 'called with unsupported method' do
      specify do
        expect { subject.request :koza, 'fafarafa' }.
          to raise_error(RuntimeError, 'Unsupported method "koza"')
      end
    end

    context 'called with supported method' do
      before do
        stub_request(:get, endpoint_uri('somepath/')).
            with(headers: {'X-Api-Key'=>'87a7da987da98sd7a98'}).
            to_return(body: generate_body(some: 'response'))
      end

      specify do
        expect(subject.request(:get, 'somepath/')).to eq('some' => 'response')
      end
    end

    context 'called with supported method returning an error' do
      before do
        stub_request(:post, endpoint_uri('instances/')).
            with(body: { 'name' => 'koza' },
                 headers: {'X-Api-Key'=>'87a7da987da98sd7a98'}).
           to_return(body: generate_body({name: ['This field is required.']}),
                     status: 400)
      end

      specify do
        expect { subject.request(:post, '/v1/instances/', { name: "koza" }) }.
            to raise_error(Syncano::ClientError)
      end
    end
  end

  describe '#authenticate' do
    subject { described_class.new }

    let(:authenticate_uri) { endpoint_uri('account/auth/') }
    let(:email) { 'kiszka@koza.com' }
    let(:password) { 'kiszonka' }
    let(:success_status) { 200 }
    let(:unauthorized_status) { 401 }

    context 'successful' do
      before do
        stub_request(:post, authenticate_uri).
          with(body: { 'email' => email, 'password' => password } ).
          to_return(body: successful_body, status: success_status)
      end

      it 'should get an API key' do
        expect { subject.authenticate(email, password) }.to change { subject.authenticated? }
      end

      def successful_body
        generate_body id: 15,
          email: email,
          first_name: '',
          last_name: '',
          account_key: 'kozakoza123'
      end
    end

    context 'failed' do
      before do
        stub_request(:post, authenticate_uri).
          with(body: { 'email' => email, 'password' => password }).
          to_return(body: failed_body, status: unauthorized_status)

      end

      it 'should raise an exception' do
        expect { subject.authenticate(email, password) }.to raise_error(Syncano::ClientError)
      end

      def failed_body
        generate_body detail: 'Invalid email or password.'
      end
    end
  end

  def generate_body(params)
    JSON.generate params
  end
end
