require 'spec_helper'

describe 'Using resources through sync api' do
  it 'should create new project in Syncano' do
    count_before = @sync_client.projects.count
    @sync_client.projects.create(name: 'Test project', description: 'Just testing')
    count_after = @sync_client.projects.count

    (count_after - count_before).should == 1
    @sync_client.projects.last[:name].should == 'Test project'
  end

  it 'should get projects' do
    projects = @sync_client.projects.all
    projects.each do |project|
      project.id.should_not be_nil
      project[:name].should_not be_nil
    end
  end

  it 'should get one project' do
    projects = @sync_client.projects.all

    project = @sync_client.projects.find(projects.last.id)
    project[:name].should == projects.last[:name]
  end

  it 'should destroy project' do
    count_before = @sync_client.projects.count
    @sync_client.projects.last.destroy
    count_after = @sync_client.projects.count

    (count_before - count_after).should == 1
  end
end