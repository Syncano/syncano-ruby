require 'spec_helper'

describe 'Syncano::Resource::Project' do
  it 'should create new project in Syncano' do
    count_before = @client.projects.count
    @client.projects.create(name: 'Test project', description: 'Just testing')
    count_after = @client.projects.count

    (count_after - count_before).should == 1
    @client.projects.last[:name].should == 'Test project'
  end

  it 'should get projects' do
    projects = @client.projects.all
    projects.each do |project|
      project.id.should_not be_nil
      project[:name].should_not be_nil
    end
  end

  it 'should get one project' do
    projects = @client.projects.all

    project = @client.projects.find(projects.last.id)
    project[:name].should == projects.last[:name]
  end

  it 'should destroy project' do
    count_before = @client.projects.count
    @client.projects.last.destroy
    count_after = @client.projects.count

    (count_before - count_after).should == 1
  end
end