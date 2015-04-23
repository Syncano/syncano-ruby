require_relative '../spec_helper'

WebMock.allow_net_connect!

describe Syncano do
  before(:all) do
    @api_key = ENV['INTEGRATION_TEST_API_KEY']
    @api = Syncano.connect(api_key: @api_key)
  end

  before(:each) do
    @api.instances.all.each &:destroy
    @instance = @api.instances.create(name: "a#{SecureRandom.hex(24)}")
    @instance.classes.all.select { |c| c.name != 'user_profile'}.each &:destroy
    @instance.groups.all.each &:destroy
    @instance.users.all.each &:delete
  end

  let(:group) { @instance.groups.create name: 'wheel' }

  describe 'working with instances' do
    subject { @api.instances }

    it 'should raise an error on not found instance' do
      expect { subject.find('kaszanka') }.to raise_error(Syncano::ClientError)
    end

    specify do
      subject.create name: 'fafarafa'
    end
  end

  describe 'working with classes' do
    subject { @instance.classes }

    specify do
      expect { subject.create name: 'sausage', schema: [{name: 'name', type: 'string' }], group: group.primary_key }.to create_resource

      new_klass = subject.last

      expect(new_klass.name).to eq('sausage')
      expect(new_klass.schema).to eq([{'name' => 'name', 'type' => 'string'}])

      new_klass.description = 'salchichón'
      new_klass.schema = [{name: 'nombre', type: 'string'}]

      saved_class =  new_klass.save
      expect(resources_count).to eq(2)
      expect(saved_class.schema).to eq([{'name' => 'nombre', 'type' => 'string'}])
      expect(saved_class.description).to eq('salchichón')

      from_database = subject.last
      expect(from_database.schema).to eq([{'name' => 'nombre', 'type' => 'string'}])
      expect(from_database.description).to eq('salchichón')
    end
  end

  describe 'working with objects' do
    before do
      @owner = @instance.users.create username: 'admin', password: 'dupa.8'
      @class = @instance.classes.create name: 'account',
                                        group: group.primary_key,
                                        schema: [{name: 'currency', type: 'string', filter_index: true},
                                                 {name: 'ballance', type: 'integer', filter_index: true, order_index: true}]
    end

    subject { @class.objects }


    specify 'basic operations' do
      expect { subject.create currency: 'USD', ballance: 1337, group: group.primary_key, owner: @owner.primary_key }.to create_resource

      object = subject.first

      expect(object.ballance).to eq(1337)
      expect(object.currency).to eq('USD')

      object.currency = 'GBP'
      object.ballance = 54
      object.save

      expect(object.ballance).to eq(54)
      expect(object.currency).to eq('GBP')

      expect { object.destroy }.to destroy_resource
    end


    specify 'PATH and POST' do
      subject.create currency: 'CNY', ballance: 98123, group: group.primary_key, owner: @owner.primary_key

      yuan = subject.first
      new_yuan = subject.first

      yuan.ballance = 100000
      yuan.save

      new_yuan.currency = 'RMB'
      new_yuan.save

      yuan = subject.first

      expect(yuan.currency).to eq('RMB')
      expect(yuan.ballance).to eq(10000)
    end

    specify 'filtering and ordering' do
      usd = subject.create(currency: 'USD', ballance: 400, group: group.primary_key, owner: @owner.primary_key)
      pln = subject.create(currency: 'PLN', ballance: 1600, group: group.primary_key, owner: @owner.primary_key)
      eur = subject.create(currency: 'EUR', ballance: 400, group: group.primary_key, owner: @owner.primary_key)
      gbp = subject.create(currency: 'GPB', ballance: 270, group: group.primary_key, owner: @owner.primary_key)
      chf = subject.create(currency: 'CHF', ballance: 390, group: group.primary_key, owner: @owner.primary_key)
      uah = subject.create(currency: 'UAH', ballance: 9100, group: group.primary_key, owner: @owner.primary_key)
      rub = subject.create(currency: 'RUB', group: group.primary_key, owner: @owner.primary_key)

      expect(subject.all(query: { ballance: { _exists: true }}).to_a).to_not include(rub)
      expect(subject.all(query: { currency: { _in: %w[UAH USD PLN] } }).to_a).to match_array([pln, usd, uah])
      expect(subject.all(query: { ballance: { _lt: 400, _gte: 270 }}, order_by: '-ballance').to_a).to eq([chf, gbp])
    end

    specify 'fetching only specific fields' do
      usd = subject.create(currency: 'USD', ballance: 400, group: group.primary_key, owner: @owner.primary_key)

      account = subject.all(fields: 'currency').first
      expect { account.currency }.to_not raise_error
      expect { account.ballance }.to raise_error(NoMethodError)


      account = subject.first(excluded_fields: 'currency')
      expect { account.currency }.to raise_error(NoMethodError)
      expect { account.ballance }.to_not raise_error
    end

    specify 'paging', slow: true do
      104.times { subject.create group: group.primary_key, owner: @owner.primary_key }

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

      expect(total).to eq(104)
    end
  end

  describe 'working with codeboxes traces' do
    subject { @instance.codeboxes }


    specify 'basic operations' do
      expect { subject.create name: 'df', source: 'puts 1337', runtime_name: 'ruby' }.to create_resource

      codebox = subject.first
      codebox.run
      codebox.source = 'puts 123'
      codebox.save
      codebox.run

      without_profiling { sleep 5 }
      traces = codebox.traces.all

      expect(traces.count).to eq(2)

      first = traces[1]

      expect(first.status).to eq('success')
      expect(first.result).to eq('1337')

      second = traces[0]
      expect(second.status).to eq('success')
      expect(second.result).to eq('123')

      expect { @instance.schedules.create name: 'test', interval_sec: 30, codebox: codebox.primary_key }.
          to change { @instance.schedules.all.count }.by(1)

      expect { codebox.destroy }.to destroy_resource
    end
  end

  describe 'working with webhooks' do
    subject { @instance.webhooks }

    let!(:codebox) { @instance.codeboxes.create name: 'wurst', source: 'puts "currywurst"', runtime_name: 'ruby' }

    specify do
      expect { subject.create slug: 'web-wurst', codebox: codebox.primary_key }.to create_resource

      expect(subject.first.run['result']).to eq('currywurst')

      expect { subject.first.destroy }.to destroy_resource
    end
  end

  def resources_count
    subject.all.count
  end

  def create_resource
    change { resources_count }.by(1)
  end

  def destroy_resource
    change { resources_count }.to(0)
  end

  def without_profiling
    if defined? RubyProf
      begin
        RubyProf.pause if RubyProf.running?
        yield
      ensure
        RubyProf.resume if RubyProf.running?
      end
    else
      yield
    end
  end
end