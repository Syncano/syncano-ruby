require_relative '../spec_helper'


require 'rspec/expectations'

describe Syncano::Resources::Base do
  subject do
    Syncano::Schema.send(:new_resource_class,
          {:attributes => {'name' => {'read_only' => false,
                                      'primary_key' => true,
                                      'required' => true,
                                      'label' => 'name',
                                      'max_length' => 64,
                                      'type' => 'string'},

                           'created_at' => {'read_only' => true,
                                            'required' => false,
                                            'type' => 'datetime',
                                            'label' => 'created at'},
                           'updated_at' => {'read_only' => true,
                                            'required' => false,
                                            'type' => 'datetime',
                                            'label' => 'updated at'},
                           'role' => {'read_only' => true,
                                      'required' => false,
                                      'type' => 'field'},
                           'owner' => {'first_name' => {'read_only' => false,
                                                        'max_length' => 35,
                                                        'required' => false,
                                                        'type' => 'string',
                                                        'label' => 'first name'},
                                       'last_name' => {'read_only' => false,
                                                       'max_length' => 35,
                                                       'required' => false,
                                                       'type' => 'string',
                                                       'label' => 'last name'},
                                       'id' => {'read_only' => true,
                                                'required' => false,
                                                'type' => 'integer',
                                                'label' => 'ID'},
                                       'email' => {'read_only' => false,
                                                   'max_length' => 254,
                                                   'required' => true,
                                                   'type' => 'email',
                                                   'label' => 'email address'}},
                           'metadata' => {'read_only' => false,
                                          'required' => false,
                                          'type' => 'field',
                                          'label' => 'metadata'},
                           'description' => {'read_only' => false,
                                             'required' => false,
                                             'type' => 'string',
                                             'label' => 'description'}},
           :associations => {'read_only' => true,
                             'required' => false,
                             'type' => 'links',
                             'links' => [{'type' => 'detail',
                                          'name' => 'self'},
                                         {'type' => 'list',
                                          'name' => 'admins'},
                                         {'type' => 'list',
                                          'name' => 'classes'},
                                         {'type' => 'list',
                                          'name' => 'codeboxes'},
                                         {'type' => 'list',
                                          'name' => 'runtimes'},
                                         {'type' => 'list',
                                          'name' => 'invitations'},
                                         {'type' => 'list',
                                          'name' => 'api_keys'},
                                         {'type' => 'list',
                                          'name' => 'triggers'},
                                         {'type' => 'list',
                                          'name' => 'webhooks'}]},
           :collection => {:path => '/v1/instances/',
                           :http_methods => ['post',
                                             'get'],
                           :params => []},
           :member => {:path => '/v1/instances/{name}/',
                       :http_methods => ['put',
                                         'get',
                                         'patch',
                                         'delete'],
                       :params => ['name']},
           :custom_methods => []},
          'some_name'
    )
  end

  let(:connection) { double('connection')}
  let(:scope_parameters) { double('scope_parameters')}

  describe '.find' do
    let(:response) {
      {'name'=>'kozakoza',
       'links'=>{'runtimes'=>'/v1/instances/kozakoza/codeboxes/runtimes/',
                 'triggers'=>'/v1/instances/kozakoza/triggers/',
                 'self'=>'/v1/instances/kozakoza/',
                 'invitations'=>'/v1/instances/kozakoza/invitations/',
                 'admins'=>'/v1/instances/kozakoza/admins/',
                 'classes'=>'/v1/instances/kozakoza/classes/',
                 'webhooks'=>'/v1/instances/kozakoza/webhooks/',
                 'api_keys'=>'/v1/instances/kozakoza/api_keys/',
                 'codeboxes'=>'/v1/instances/kozakoza/codeboxes/'},
       'created_at'=>'2015-02-27T16:57:08.475612Z',
       'updated_at'=>'2015-02-27T16:57:08.483462Z',
       'role'=>'full',
       'owner'=>{'first_name'=>'',
                 'last_name'=>'',
                 'id'=>124,
                 'email'=>'maciej.lotkowski@gmail.com'},
       'metadata'=>{},
       'description'=>''}

    }
    before do
      expect(connection).to receive(:request).and_return(response)
    end

    it 'should find a resource' do
      subject.find(connection, scope_parameters, 'PK')
    end
  end

  describe '.all' do
    let(:response) { { 'objects' => [{}] } }

    before do
      expect(connection).to receive(:request).and_return(response)
    end

    it 'should get collection of resources' do
      expect(subject.all(connection, {})).to be_a(Syncano::Resources::Collection)
    end
  end

  describe '.new' do
    it 'should instantiate new resource' do
      expect(subject.new(connection, {}, {}, true)).to be_a subject
    end

    it 'should init attributes' do
      resource = subject.new(connection, {}, { name: 'test' }, true)
      expect(resource.name).to eq('test')
    end

    it 'should clean changes if initialized from database' do
      resource = subject.new(connection, {}, { links: { self: '/v1/instances/test/' }, name: 'test' }, true)
      expect(resource.changed?).to eq(false)
    end

    it 'should keep changes if not initialized from database' do
      resource = subject.new(connection, {}, { links: { self: '/v1/instances/test/' }, name: 'test' }, false)
      expect(resource.changed?).to eq(true)
    end

    it 'should mark resource as not new if initialized with self path' do
      resource = subject.new(connection, {}, { links: { self: '/v1/instances/test/' } }, true)
      expect(resource.new_record?).to be(false)
    end

    it 'should mark resource as new if initialized without self path' do
      resource = subject.new(connection, {}, { name: 'test' }, true)
      expect(resource.new_record?).to be(true)
    end
  end

  describe '.create' do
    it 'should create new object in Syncano' do

    end
  end

  describe '.update_attributes' do
    it 'should create update object\'s attributes in Syncano' do

    end
  end

  describe '.destroy' do
    it 'should delete object from Syncano' do

    end
  end
end