require 'spec_helper'

describe 'Syncano::Resource::Collection' do
  before(:all) do
    @project = @client.projects.last || @client.projects.create(name: 'Test project')
  end

  it 'should create a new collection in Syncano' do
    count_before = @project.collections.count

    collection = @project.collections.create(name: 'Test collection', description: 'Just testing')
    collection.id.should_not be_nil

    count_after = @project.collections.count

    (count_after - count_before).should == 1
    @project.collections.last[:name].should == 'Test collection'
  end

  it 'should get all collections' do
    @project.collections.all.each do |collection|
      collection.id.should_not be_nil
      collection[:name].should_not be_nil
    end
  end

  it 'should get a one collection' do
    collection = @project.collections.last
    @project.collections.find(collection.id)[:name].should == collection[:name]
  end

  it 'should activate inactive collection' do
    collection = @project.collections.last

    if collection[:status] == 'active'
      collection.deactivate
      collection.reload!
    end
    collection[:status].should == 'inactive'

    collection.activate
    collection.reload!
    collection['status'].should == 'active'
  end

  it 'should deactivate active collection' do
    collection = @project.collections.last

    if collection[:status] == 'inactive'
      collection.activate
      collection.reload!
    end
    collection[:status].should == 'active'

    collection.deactivate
    collection.reload!
    collection[:status].should == 'inactive'
  end

  it 'should destroy a collection' do
    count_before = @project.collections.count
    @project.collections.last.destroy
    count_after = @project.collections.count

    (count_before - count_after).should == 1
  end
end