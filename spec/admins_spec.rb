require 'spec_helper'

describe 'Syncano::Resource::Admin' do
  it 'should get admins' do
    @client.admins.all.each do |admin|
      admin.id.should_not be_nil
      admin[:email].should_not be_nil
    end
  end

  it 'should get one admin' do
    admins = @client.admins.all

    @client.admins.find(admins.last.id)[:name].should == admins.last[:name]
    @client.admins.find_by_email(admins.last[:email])[:email].should == admins.last[:email]
  end
end