require 'spec_helper'

describe 'Syncano::Resource::Collection' do
  config.before(:all) do
    @project = @client.projects.all.data.first
    if @project.nil?
      @client.projects.create(name: 'Test project')
      @project = @client.projects.all.data.first
    end
  end

  it 'should create a new collection in Syncano' do
    all_collections_before = @client.collections(@project['id']).all

    response = @client.collections(@project['id']).create(name: 'Test collection', description: 'Just testing')
    response.status.should == true

    all_collections_after = @client.collections(@project['id']).all

    (all_collections_after.data.count - all_collections_before.data.count).should == 1
    all_collections_after.data.last['name'].should == 'Test collection'
  end

  it 'should get all collections' do
    all_collections = @client.collections(@project['id']).all
    all_collections.status.should == true

    all_collections.data.each do |collection_data|
      expect(collection_data.keys).to include('id')
      collection_data['id'].should_not be_nil
      expect(collection_data.keys).to include('name')
      collection_data['name'].should_not be_nil
    end
  end

  it 'should get a one collection' do
    collections_data = @client.collections(@project['id']).all.data.last

    collection_data = @client.collections(@project['id']).find(collections_data.data.last['id'])
    collection_data.data['name'].should == projects_data.data.last['name']
  end

  it 'should activate inactive collection' do
    collection = @client.collections(@project['id']).all.data.last
    if collection['status'] == 'active'
      @client.collections.deactivate(collection['id'])
      collection = @client.collections(@project['id']).find(collection['id']).data
    end

    collection['status'].should == 'inactive'
    @client.collections(@project['id']).activate(collection['id'])

    collection = @client.collections(@project['id']).find(collection['id']).data
    collection['status'].should == 'active'
  end

  it 'should deactivate active collection' do
    collection = @client.collections(@project['id']).all.data.last
    if collection['status'] == 'inactive'
      @client.collections.activate(collection['id'])
      collection = @client.collections(@project['id']).find(collection['id']).data
    end

    collection['status'].should == 'active'
    @client.collections(@project['id']).activate(collection['id'])

    collection = @client.collections(@project['id']).find(collection['id']).data
    collection['status'].should == 'inactive'
  end

  it 'should destroy a collection' do
    all_collections_before = @client.collections(@project['id']).all
    collection_id = all_collections_before.data.last['id']
    @client.collections(@project['id']).destroy(collection_id)
    all_collections_after = @client.collections(@project['id']).all

    (all_collections_before.data.count - all_collections_after.data.count).should == 1
  end
end