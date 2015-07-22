require_relative '../spec_helper'

WebMock.allow_net_connect!

describe Syncano do
  before(:all) do
    @api_key = ENV['INTEGRATION_TEST_API_KEY']
    @api = Syncano.connect(api_key: @api_key)
  end

  before(:each) do
    @api.instances.all.each &:destroy
    @instance = @api.instances.create(name: instance_name )
    @instance.classes.all.select { |c| c.name != 'user_profile'}.each &:destroy
    @instance.groups.all.each &:destroy
    @instance.users.all.each &:delete
  end

  let(:instance_name) { "a#{SecureRandom.hex(24)}" }
  let(:group) { @instance.groups.create name: 'wheel' }

  describe 'working with instances' do
    subject { @api.instances }

    it 'should raise an error on not found instance' do
      expect { subject.find('kaszanka') }.to raise_error(Syncano::NotFound)
    end

    specify do
      subject.create name: 'fafarafaa'
    end
  end

  describe 'working with classes' do
    subject { @instance.classes }

    specify do
      expect { subject.create name: 'sausage', schema: [{name: 'name', type: 'string' }] }.to create_resource

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
      @class = @instance.classes.create name: 'account',
                                        schema: [{name: 'currency', type: 'string', filter_index: true},
                                                 {name: 'ballance', type: 'integer', filter_index: true, order_index: true}]
    end

    subject { @class.objects }


    specify 'basic operations' do
      expect { subject.create currency: 'USD', ballance: 1337 }.to create_resource

      object = subject.first

      expect(object.ballance).to eq(1337)
      expect(object.currency).to eq('USD')

      object.currency = 'GBP'
      object.ballance = 54
      object.save

      expect(object.ballance).to eq(54)
      expect(object.currency).to eq('GBP')

      expect { subject.destroy(object.primary_key) }.to destroy_resource
    end


    specify 'PATH and POST' do
      initial_yuan = subject.create currency: 'CNY', ballance: 98123

      yuan = subject.first
      new_yuan = subject.first

      yuan.ballance = 100000
      yuan.save

      new_yuan.currency = 'RMB'
      new_yuan.save

      yuan = subject.first

      expect(yuan.currency).to eq('RMB')
      expect(yuan.ballance).to eq(100000)

      initial_yuan.save(overwrite: true)
      yuan.reload!

      expect(yuan.currency).to eq('CNY')
      expect(yuan.ballance).to eq(98123)
    end

    specify 'filtering and ordering' do
      usd = subject.create(currency: 'USD', ballance: 400)
      pln = subject.create(currency: 'PLN', ballance: 1600)
      eur = subject.create(currency: 'EUR', ballance: 400)
      gbp = subject.create(currency: 'GPB', ballance: 270)
      chf = subject.create(currency: 'CHF', ballance: 390)
      uah = subject.create(currency: 'UAH', ballance: 9100)
      rub = subject.create(currency: 'RUB')

      expect(subject.all(query: { ballance: { _exists: true }}).to_a).to_not include(rub)
      expect(subject.all(query: { currency: { _in: %w[UAH USD PLN] } }).to_a).to match_array([pln, usd, uah])
      expect(subject.all(query: { ballance: { _lt: 400, _gte: 270 }}, order_by: '-ballance').to_a).to eq([chf, gbp])
    end

    specify 'fetching only specific fields' do
      subject.create(currency: 'USD', ballance: 400)

      account = subject.all(fields: 'currency').first
      expect { account.currency }.to_not raise_error
      expect { account.ballance }.to raise_error(NoMethodError)


      account = subject.first(excluded_fields: 'currency')
      expect { account.currency }.to raise_error(NoMethodError)
      expect { account.ballance }.to_not raise_error
    end

    specify 'paging', slow: true do
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

      expect(total).to eq(104)
    end
  end

  describe 'working with codeboxes traces' do
    subject { @instance.codeboxes }


    specify 'basic operations' do
      expect { subject.create label: 'df', source: 'puts 1337', runtime_name: 'ruby' }.to create_resource

      codebox = subject.first
      codebox.run
      codebox.source = 'puts 123'
      codebox.save
      codebox.run

      without_profiling { sleep 10 }
      traces = codebox.traces.all

      expect(traces.count).to eq(2)

      first = traces[1]

      expect(first.status).to eq('success')
      expect(first.result["stdout"]).to eq('1337')

      second = traces[0]
      expect(second.status).to eq('success')
      expect(second.result["stdout"]).to eq('123')

      expect { @instance.schedules.create label: 'test', interval_sec: 30, codebox: codebox.primary_key }.
          to change { @instance.schedules.all.count }.by(1)

      expect { codebox.destroy }.to destroy_resource
    end
  end

  describe 'working with webhooks' do
    subject { @instance.webhooks }

    describe 'using the gem' do
      let!(:codebox) { @instance.codeboxes.create label: 'wurst', source: 'puts "currywurst"', runtime_name: 'ruby' }

      specify do
        expect { subject.create name: 'web-wurst', codebox: codebox.primary_key }.to create_resource

        expect(subject.first.run['result']["stdout"]).to eq('currywurst')

        expect { subject.first.destroy }.to destroy_resource
      end
    end

    describe 'using curl' do
      let(:source) {
        <<-SOURCE
          p ARGS["POST"]
        SOURCE
      }
      let!(:codebox) { @instance.codeboxes.create label: 'curl', source: source, runtime_name: 'ruby' }
      let!(:webhook) { subject.create name: 'web-curl', codebox: codebox.primary_key, public: true }

      specify do
        url = "#{ENV['API_ROOT']}/v1/instances/#{instance_name}/webhooks/p/#{webhook.public_link}/"
        code = %{curl -k --form kiszka=koza -H "kiszonka: 007" -X POST #{url} 2>/dev/null}
        output = JSON.parse(`#{code}`)

        expect(output["status"]).to eq("success")
        expect(output["result"]["stdout"]).to eq('{"kiszka"=>"koza"}')
      end
    end
  end

  describe 'working with API keys' do
    subject { @instance.api_keys }

    specify do
      api_key = nil

      expect {
        api_key = subject.create allow_user_create: true
      }.to create_resource

      expect { api_key.destroy }.to destroy_resource
    end
  end

  describe 'managing users' do
    subject { @instance.users }

    specify do
      user = nil

      expect {
        user = subject.create(username: 'koza', password: 'kiszkakoza')
      }.to create_resource

      user.update_attributes username: 'kiszka'
      expect(subject.find(user.primary_key).username).to eq('kiszka')

      expect { user.destroy }.to destroy_resource
    end
  end

  describe 'managing groups' do
    subject { @instance.groups }

    specify do
      creator = @instance.users.create username: 'content', password: 'creator'

      content_creators = nil

      expect {
        content_creators = subject.create label: 'content creators'
      }.to create_resource

      expect {
        content_creators.users.create user: creator.primary_key
      }.to change { content_creators.users.all.count }.from(0).to(1)

      expect { content_creators.destroy }.to destroy_resource
    end
  end

  describe 'managing channels' do
    subject do
      @instance.channels
    end

    specify do
      channel = nil
      expect { channel = subject.create(name: 'chat') }.to create_resource
      expect { channel.destroy }.to destroy_resource
    end
  end


  describe 'subscribing to a channel' do
    before(:each) { Celluloid.boot }

    after(:each) { Celluloid.shutdown }

    let!(:notifications) do
      @instance.classes.create(name: 'notifications', schema: [{name: 'message', type: 'string'}]).objects
    end

    let!(:notifications_channel) do
      @instance.channels.create name: 'system-notifications', other_permissions: 'subscribe'
    end

    specify do
      poller = notifications_channel.poll

      notifications.create message: "A new koza's arrived", channel: 'system-notifications'

      expect(poller.responses).to_not be_empty
      expect(poller.responses.size).to eq(1)
      expect(JSON.parse(poller.responses.last.body)["payload"]["message"]).to eq("A new koza's arrived")

      poller.terminate
    end
  end

  describe 'using syncano on behalf of the user' do
    let(:user_api_key) { @instance.api_keys.create.api_key }
    let(:user) {
      @instance.users.create username: 'kiszonka', password: 'passwd'
    }
    let(:another_user) {
      @instance.users.create username: 'another', password: 'user'
    }
    let(:user_instance) {
      Syncano.connect(api_key: user_api_key, user_key: user.user_key).
        instances.first
    }
    let(:another_user_instance) {
      Syncano.connect(api_key: user_api_key, user_key: another_user.user_key).
        instances.first
    }
    let(:group) { @instance.groups.create label: 'content creators' }

    before do
      group.users.create user: user.primary_key
      group.users.create user: another_user.primary_key

      @instance.classes.create name: 'book',
                               schema: [{ name: 'title', type: 'string' }],
                               group: group.primary_key,
                               group_permissions: 'create_objects'
    end


    specify do
      owner_books = user_instance.classes.find('book').objects
      book = owner_books.create(title: 'Oliver Twist', owner_permissions: 'write')

      expect(owner_books.all.to_a).to_not be_empty

      group_member_books = another_user_instance.classes.find('book').objects
      expect(group_member_books.all.to_a).to be_empty

      book.group_permissions = 'read'
      book.group = group.primary_key
      book.save

      expect(group_member_books.all.to_a).to_not be_empty
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