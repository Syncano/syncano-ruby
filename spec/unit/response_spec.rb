require 'spec_helper'

describe Syncano::Response do
  describe '.handle' do
    context 'success' do
      let(:raw_response) { double :raw_response,
                                  body: generate_body(some: 'response'),
                                  status: status(200) }

      specify do
        expect(described_class.handle(raw_response)).to eq('some' => 'response')
      end
    end

    context 'not found' do
      let(:env) { double :env, url: 'http://path', method: :get }
      let(:raw_response) { double :raw_response,
                                  body: nil,
                                  status: status(404),
                                  env: env }

      specify do
        expect { described_class.handle(raw_response) }.to raise_error(Syncano::NotFound)
      end
    end

    context 'client error' do
      let(:raw_response) {
        double :raw_response, body: generate_body({name: ['This field can not be "koza"']}),
          status: status(400)
      }

      specify do
        expect { described_class.handle(raw_response) }.to raise_error(Syncano::ClientError)
      end
    end

    context 'returning a server error' do
      let(:raw_response) { double :raw_response,
                                  body: 'server error',
                                  status: status(500) }

      specify do
        expect { described_class.handle(raw_response) }.
          to raise_error(Syncano::ServerError)
      end
    end

    context 'unsupported status code' do
      let(:raw_response) { double :raw_response,
                            body: 'fafarafa',
                            status: status(112) }

      specify do
        expect { described_class.handle(raw_response) }.to raise_error(Syncano::UnsupportedStatusError)
      end
    end

    context 'successful returning empty body' do
      let(:raw_response) { double :raw_response, status: status(204) }

      specify do
        expect(described_class.handle(raw_response)).to eq(nil)
      end
    end
  end

  def generate_body(params)
    JSON.generate params
  end

  def status(code)
    double :status, code: code
  end
end
