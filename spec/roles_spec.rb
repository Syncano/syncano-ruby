require 'spec_helper'

describe 'Syncano::Resource::Role' do
  it 'should get roles' do
    roles = @client.roles.all
    roles.count.should_not == 0

    roles.each do |role|
      role.id.should_not be_nil
      role[:name].should_not be_nil
    end
  end
end