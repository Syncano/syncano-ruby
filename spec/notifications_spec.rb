require 'spec_helper'

describe 'Handling notifications' do
  before(:all) do
    @project = @sync_client.projects.last || @sync_client.projects.create(name: 'Test project')
    @collection = @project.collections.last || @project.collections.create(name: 'Test collection')
    @object = @collection.data_objects.last || @collection.data_objects.create(title: 'Test object')
    @object.update(title: 'Test object')
    sleep 3

    @sync_client.append_callback(:test) do |notification|
      p "Notification received: #{notification.inspect}"
    end
  end

  it 'should subscribe to project' do
    @project.subscribe
    p 'Notification should be seen'
    @object.update(title: 'Test object 2')
    sleep 3
  end

  it 'should unsubscribe from project' do
    @project.unsubscribe
    p 'Notification should not be seen'
    @object.update(title: 'Test object 3')
    sleep 3
  end

  it 'should subscribe to collection' do
    @collection.subscribe
    p 'Notification should be seen'
    @object.update(title: 'Test object 4')
    sleep 3
  end

  it 'should unsubscribe from collection' do
    @collection.unsubscribe
    p 'Notification should not be seen'
    @object.update(title: 'Test object 5')
    sleep 3
  end
end