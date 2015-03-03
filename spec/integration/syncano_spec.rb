require_relative '../spec_helper'

WebMock.allow_net_connect!

describe Syncano do
  before(:all) do
    @api = Syncano.connect(api_key: ENV['INTEGRATION_TEST_API_KEY'])
    @api.instances.all.each &:destroy

    @instance = @api.instances.create(name: 'butchers')
  end

  it 'should raise an error on not found instance' do
    expect { @api.instances.find('kaszanka') }.to raise_error(Syncano::ClientError)
  end

  it 'work with classes and objects' do
    klass = @instance.classes.create(name: 'sausage', schema: [{name: 'name', type: 'string' }])

    expect(klass.objects.all.count).to eq(0)

    %w[kaszanka kiszka wurst].each do |name|
      klass.objects.create name: name
    end

    expect(klass.objects.all.count).to eq(3)
  end
end