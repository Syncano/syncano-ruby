require_relative '../spec_helper'


describe Syncano do
  describe "#connect" do
    let(:email) { 'kiszka@koza.com' }
    let(:password) { 'kiszonka' }
    let(:options) { { email: email, password: password } }
    let(:api_key) { 'kozakoza123' }

    before do
      stub_request(:post, endpoint_uri('account/auth/')).
          with(body: options).
          to_return(status: 200,
                    body: generate_body(id: 15, email: email, first_name: '', last_name: '', account_key: api_key))

      stub_request(:get, endpoint_uri('schema/')).
          with(headers: { 'X-Api-Key' => api_key }).
          to_return(status: 200, body: generate_body([]))

      expect_any_instance_of(Syncano::Connection).
        to receive(:authenticated?)
    end

    specify { expect(Syncano.connect(options)).to be_kind_of(Syncano::API) }
  end
end