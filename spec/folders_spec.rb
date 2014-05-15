require 'spec_helper'

describe 'Syncano::Resource::Folder' do
  before(:all) do
    @project = @client.projects.last || @client.projects.create(name: 'Test project')
    @collection = @project.collections.last || @project.collections.create(name: 'Test collection')
  end

  it 'should create new folder in Syncano' do
    count_before = @collection.folders.count
    folder = @collection.folders.create(name: 'Test folder')
    count_after = @collection.folders.count

    (count_after - count_before).should == 1
    @collection.folders.last[:name].should == 'Test folder'
  end

  it 'should get folders' do
    @collection.folders.all.each do |folder|
      folder.id.should_not be_nil
      folder[:name].should_not be_nil
    end
  end

  it 'should get one folder' do
    folder = @collection.folders.last
    @collection.folders.find(folder[:name])[:name].should == folder[:name]
    @collection.folders.find_by_name(folder[:name])[:name].should == folder[:name]
  end

  it 'should destroy folder' do
    count_before = @collection.folders.count
    @collection.folders.last.destroy
    count_after = @collection.folders.count

    (count_before - count_after).should == 1
  end
end