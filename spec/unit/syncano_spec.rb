require_relative '../spec_helper'


describe Syncano do
  describe '#connect' do
    let(:email) { 'kiszka@koza.com' }
    let(:password) { 'kiszonka' }
    let(:email_options) { { email: email, password: password } }
    let(:api_key) { 'kozakoza123' }

    context 'with credentials in options' do
      context 'email and password' do
        before do
          stub_auth_request
          stub_schema_request
        end

        specify do
          expect(Syncano.connect(email_options)).to be_kind_of(Syncano::API)
        end
      end

      context 'api key' do
        before do
          stub_schema_request
        end

        specify do
          expect(Syncano.connect(api_key: api_key)).to be_kind_of(Syncano::API)
        end
      end
    end

    context 'with credentials in ENV variables' do
      before do
        @old_api_key = ENV['SYNCANO_API_KEY']
        ENV['SYNCANO_API_KEY'] = api_key

        stub_schema_request
      end

      after do
        ENV['SYNCANO_API_KEY'] = @old_api_key
      end

      specify { expect(Syncano.connect).to be_kind_of(Syncano::API) }
    end

    def stub_schema_request
      stub_request(:get, endpoint_uri('schema/'))
          .with(headers: { 'X-Api-Key' => api_key })
          .to_return(status: 200, body: generate_body([]))
    end

    def stub_auth_request
      stub_request(:post, endpoint_uri('account/auth/'))
          .with(body: email_options)
          .to_return(status: 200,
                     body: generate_body(id: 15, email: email, first_name: '', last_name: '', account_key: api_key))
    end

  end
end
