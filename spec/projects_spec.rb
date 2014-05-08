require 'spec_helper'

describe 'Syncano::Resource::Project' do
  context 'Syncano::Resource::Project' do
    it 'should create new project in Syncano' do
      all_projects_before = @client.projects.all

      response = @client.projects.create(name: 'Test project', description: 'Just testing')
      response.status.should == true

      all_projects_after = @client.projects.all

      (all_projects_after.data.count - all_projects_before.data.count).should == 1
      all_projects_after.data.last['name'].should == 'Test project'
    end

    it 'should get projects' do
      all_projects = @client.projects.all
      all_projects.status.should == true

      all_projects.data.each do |project_data|
        expect(project_data.keys).to include('id')
        project_data['id'].should_not be_nil
        expect(project_data.keys).to include('name')
        project_data['name'].should_not be_nil
      end
    end

    it 'should get one project' do
      projects_data = @client.projects.all

      project_data = @client.projects.find(projects_data.data.last['id'])
      project_data.data['name'].should == projects_data.data.last['name']
    end

    it 'should destroy project' do
      all_projects_before = @client.projects.all
      project_id = all_projects_before.data.last['id']
      @client.projects.destroy(project_id)
      all_projects_after = @client.projects.all

      (all_projects_before.data.count - all_projects_after.data.count).should == 1
    end
  end
end