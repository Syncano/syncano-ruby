require_relative '../../spec_helper'

describe Syncano::Resources::Collection do
  subject { described_class.from_database response, scope, element_class }

  let(:response) { { 'objects' => objects, 'prev' => previous, 'next' => subsequent } }
  let(:objects) { (1..4).to_a }
  let(:scope) { spy('scope') }
  let(:element_class) { double(new: 'blah') }
  let(:subsequent) { 'http://next' }
  let(:previous) { 'https://prev' }

  describe '#next?' do
    context 'where there is next' do
      it { is_expected.to be_next }
    end

    context 'when there is no next' do
      let(:subsequent) { nil }

      it { is_expected.not_to be_next }
    end
  end

  describe '#prev?' do
    context 'when there is prev' do
      it { is_expected.to be_prev }
    end

    context 'when there is no prev' do
      let(:previous) { nil }

      it { is_expected.not_to be_prev }
    end
  end
end