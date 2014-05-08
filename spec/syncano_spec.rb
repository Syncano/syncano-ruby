require 'spec_helper'

describe Syncano do
  it 'should allow to init a client' do
    expect(@client).to be_a(Syncano::Client)
    @client.instance_name.should == @syncano_instance_name
    @client.api_key.should == @syncano_api_key
  end
end