require 'spec_helper'

describe 'Syncano::Resource::DataObject' do
  before(:all) do
    @project = @client.projects.last || @client.projects.create(name: 'Test project')
    @collection = @project.collections.last || @project.collections.create(name: 'Test collection')
  end

  after(:all) do
    @client.batch do |q|
      @collection.data_objects.all.each do |data_object|
        q << data_object.batch.destroy
      end
    end
  end

  it 'should create new data object in Syncano' do
    count_before = @collection.data_objects.count
    @collection.data_objects.create(title: 'Test data object', additional: { test_attribute: 'test_value' })
    count_after = @collection.data_objects.count

    (count_after - count_before).should == 1
    data_object = @collection.data_objects.last
    data_object[:title].should == 'Test data object'
    data_object[:additional][:test_attribute].should == 'test_value'
  end

  it 'should copy data object in Syncano' do
    count_before = @collection.data_objects.count
    data_object = @collection.data_objects.last
    data_object.copy
    data_object_copy = @collection.data_objects.last
    count_after = @collection.data_objects.count

    (count_after - count_before).should == 1
    data_object_copy[:title].should == data_object[:title]
    data_object_copy.id.should_not == data_object.id
  end

  it 'should get data objects' do
    @collection.data_objects.all.each do |data_object|
      data_object.id.should_not be_nil
      data_object[:state].should_not be_nil
    end
  end

  it 'should check amount of objects' do
    @collection.data_objects.count.should == @collection.data_objects.all.count
  end

  it 'should get one data object' do
    data_objects = @collection.data_objects.all

    data_object = @collection.data_objects.find(data_objects.last.id)
    data_object[:title].should == data_objects.last[:title]
  end

  context 'managing parents and children' do
    before(:all) do
      @parent = @collection.data_objects.first(include_children: true)
      @parent = @collection.data_objects.create(title: "Parent object")
      @child = @collection.data_objects.last
      @child = @collection.data_objects.create(title: 'Child object') if @child.id == @parent.id
      @parent.id.should_not == @child.id
    end

    it 'should add parent to the data object' do
      @parent.remove_child(@child.id) if @parent[:children].present? && @parent[:children].map(&:id).include?(@child.id)

      @child.add_parent(@parent.id)
      @parent.reload!(include_children: true)

      @parent[:children].should_not be_nil
      @parent[:children].select{ |c| c.id == @child.id }.first.should_not be_nil
    end

    it 'should remove parent from the data object' do
      @parent.add_child(@child.id) unless @parent[:children].present? && @parent[:children].map(&:id).include?(@child.id)

      @child.remove_parent(@parent.id)
      @parent.reload!(include_children: true)

      @parent[:children].should be_nil
    end

    it 'should add child to the data object' do
      @parent.remove_child(@child.id) if @parent[:children].present? && @parent[:children].map(&:id).include?(@child.id)

      @parent.add_child(@child.id)
      @parent.reload!(include_children: true)

      @parent[:children].should_not be_nil
      @parent[:children].select{ |c| c.id == @child.id }.first.should_not be_nil
    end

    it 'should remove child from the data object' do
      @parent.add_child(@child.id) unless @parent[:children].present? && @parent[:children].map(&:id).include?(@child.id)

      @parent.remove_child(@child.id)
      @parent.reload!(include_children: true)

      @parent[:children].should be_nil
    end
  end

  it 'should destroy data object' do
    count_before = @collection.data_objects.count
    @collection.data_objects.last.destroy
    count_after = @collection.data_objects.count

    (count_before - count_after).should == 1
  end
end