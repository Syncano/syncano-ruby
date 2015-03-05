require_relative '../spec_helper'

WebMock.allow_net_connect!

describe Syncano do
  before(:all) do
    @api_key = ENV['INTEGRATION_TEST_API_KEY']
    @api = Syncano.connect(api_key: @api_key)
  end

  before(:each) do
    @api.instances.all.each &:destroy
    @instance = @api.instances.create(name: "a#{@api_key}")
  end

  describe 'working with instances' do
    subject { @api.instances }

    it 'should raise an error on not found instance' do
      expect { subject.find('kaszanka') }.to raise_error(Syncano::ClientError)
    end

    specify do
      subject.create name: 'fafarafa'
      # expect
    end
  end

  describe 'working with classes' do
    subject { @instance.classes }

    specify do
      expect { subject.create name: 'sausage', schema: [{name: 'name', type: 'string' }] }.to create_resource

      new_klass = subject.first

      expect(new_klass.name).to eq('sausage')
      expect(new_klass.schema).to eq([{'name' => 'name', 'type' => 'string'}])

      new_klass.description = 'salchichón'
      new_klass.schema = [{name: 'nombre', type: 'string'}]

      saved_class =  new_klass.save
      expect(resources_count).to eq(1)
      expect(saved_class.schema).to eq([{'name' => 'nombre', 'type' => 'string'}])
      expect(saved_class.description).to eq('salchichón')

      from_database = subject.first
      expect(from_database.schema).to eq([{'name' => 'nombre', 'type' => 'string'}])
      expect(from_database.description).to eq('salchichón')
    end
  end

  describe 'working with objects' do
    before do
      @class = @instance.classes.create name: 'account',
                                        schema: [{name: 'currency', type: 'string'},
                                                 {name: 'ballance', type: 'integer'}]
    end

    subject { @class.objects }


    specify do
      expect { subject.create currenct: 'USD', amount: 1337 }.to create_resource

      expect { subject.first.destroy }.to change { resources_count }.to(0)

      104.times { subject.create }

      total = 0

      all = subject.all

      loop do
        total += all.count

        if all.next?
          all = subject.space(all.last).all
        else
          break
        end
      end

    end
  end

  def resources_count
    subject.all.count
  end

  def create_resource
    change { resources_count }.by(1)
  end
end