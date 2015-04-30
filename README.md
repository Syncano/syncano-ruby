# Syncano 4.0 ruby gem


## Installation

Using gems:

```bash
$ gem install syncano --pre
```

## First steps

After installation, you have to set a path for api root for syncano.

If you want to use staging, export:

```bash
$ export API_ROOT=https://v4.hydraengine.com
```

If you're less adventurous, use our production api servers:

```bash
$ export=API_ROOT=https://api.syncano.io
```

Ok, now we can start coding!

```ruby
require 'syncano'

syncano = Syncano.connect(api_key: 'your-api-key')

syncano.instances.all.each { |instance| puts instance }
```

You can either pass your API key to the connect method as above or set
`ENV['SYNCANO_API_KEY']` and call just `Syncano.connect`.

## API basics

Syncano API is a nested API - all the endpointes are scoped by an instances, ex.
codeboxes path is `/instance/your_instance_name/codeboxes/`. Syncano instances
is more less a schema is in relation databases. **Your instance name must be
unique across all existing Syncano instnaces, not only limitted to your account.**


# Instances

In order to do anything with Syncano, you have to create an instances. Choose a
globally unique name and call:

```ruby
instances = syncano.instances.create name: 'my_instances_name'       
instance.first

#=> #<Syncano::Resources::Instance created_at: Sun, 26 Apr 2015 18:09:46 +0000, description: "", metadata: {}, name: "my_instance_name", owner: nil, role: "full", updated_at: Sun, 26 Apr 2015 18:09:46 +0000>
```

# Classes and objects

In order to save objects in Syncano, first you need to create a class. A class
defines objects' attributes in the class' schema. The attribute definition has two
mandatory (`name`, `type`) and two optional fields (`filter_index`, `order_index`).
What these fields are for is rather obvious - `name` defines objects' attribute
name, and `type` defines type (you can read more about available types in the 
[API docs](http://docs.syncano.com/v0.1/docs/instancesinstanceclasses-2)). `*_index`
fields are indexing. `order_index` allows you order returned collections, 
`filter_index` allows filtering in a various ways. There will be a few examples
in this README, but you can read in the 
[API docs](http://docs.syncano.com/v0.1/docs/filtering-data-objects).

```ruby
  stock = instance.classes.create name: 'stock_items',
                                  schema: [{ name: 'name', type: 'string',
                                             filter_index: true },
                                           { name: 'amount', type: 'integer',
                                             filter_index: true,
                                             order_index: true }]
```

Once we have a class, we can start creating objects. 

```ruby
  chorizo = stock.objects.create name: 'Chorizo', amount: 100
  black_pudding = stock.objects.create name: 'Black pudding', amount: 200
  curry_wurts = stock.objects.create name: 'Curry wurst', amount: 150
  kabanos = stock.objects.create name: 'Kabanos' 
  something = stock.objects.create amount: 3
```

Now we have a few items in stock, let's try filtering. 

```ruby
  stock.objects.all(order_by: '-amount', query: { amount: { _lte: 150 }, name: { _exists: true } })
  #=> #<Syncano::Resources::Collection:0x007fc18b9c7698 @next=false, @prev=false, @collection=[#<Syncano::Resources::Object amount: 150, channel: nil, channel_room: nil, created_at: Mon, 27 Apr 2015 05:21:31 +0000, group: nil, group_permissions: "none", id: 12, name: "Curry wurst", other_permissions: "none", owner: nil, owner_permissions: "none", revision: 1, updated_at: Mon, 27 Apr 2015 05:21:31 +0000>, #<Syncano::Resources::Object amount: 100, channel: nil, channel_room: nil, created_at: Mon, 27 Apr 2015 05:21:30 +0000, group: nil, group_permissions: "none", id: 10, name: "Chorizo", other_permissions: "none", owner: nil, owner_permissions: "none", revision: 1, updated_at: Mon, 27 Apr 2015 05:21:30 +0000>]> 
```

Let's give `something` a name and try again.

```ruby
  something.name = 'Unidentified sausage' 
  something.save
  
  stock.objects.all(order_by: '-amount', query: { amount: { _lte: 150 }, name: { _exists: true } })
  #=> #<Syncano::Resources::Collection:0x007fc18d58a628 @next=false, @prev=false, @collection=[#<Syncano::Resources::Object amount: 150, channel: nil, channel_room: nil, created_at: Mon, 27 Apr 2015 05:21:31 +0000, group: nil, group_permissions: \"none\", id: 12, name: \"Curry wurst\", other_permissions: \"none\", owner: nil, owner_permissions: \"none\", revision: 1, updated_at: Mon, 27 Apr 2015 05:21:31 +0000>, #<Syncano::Resources::Object amount: 100, channel: nil, channel_room: nil, created_at: Mon, 27 Apr 2015 05:21:30 +0000, group: nil, group_permissions: \"none\", id: 10, name: \"Chorizo\", other_permissions: \"none\", owner: nil, owner_permissions: \"none\", revision: 1, updated_at: Mon, 27 Apr 2015 05:21:30 +0000>, #<Syncano::Resources::Object amount: 3, channel: nil, channel_room: nil, created_at: Mon, 27 Apr 2015 05:30:18 +0000, group: nil, group_permissions: \"none\", id: 15, name: \"Unidentified sausage\", other_permissions: \"none\", owner: nil, owner_permissions: \"none\", revision: 2, updated_at: Mon, 27 Apr 2015 05:30:48 +0000>]>
```

Now it matches the query and appears in the result.

# Codeboxes

Codeboxes are small pieces of code that run on Syncano servers. You can run them
manually using the API, you can create a schedule to run them periodically, you 
can create a Webhook (and optionally make it public) to run them from the web, 
you can create a trigger to run one after a class' object is created, updated or 
deleted. There are three runtimes available: Ruby, Python and Node. This gem is 
available in Ruby runtime (just needs to be required). Let's create a simple 
codebox and run it. 

```ruby
clock = instance.codeboxes.create(name: 'clock', source: 'puts Time.now', runtime_name: 'ruby')
#=> #<Syncano::Resources::CodeBox config: {}, created_at: Thu, 30 Apr 2015 05:50:09 +0000, description: "", id: 1, name: "clock", runtime_name: "ruby", source: "puts Time.now", updated_at: Thu, 30 Apr 2015 05:50:09 +0000>
clock.run 
#=> {"status"=>"pending", "links"=>{"self"=>"gv1/instances/a523b7e842dea927d8c306ec0a9a7a4ac30191c2cd034b11d/codeboxes/1/traces/1/"}, "executed_at"=>nil, "result"=>"", "duration"=>nil, "id"=>1}
```

When you schedule a codebox run, it returns the trace. Immediately after the 
call it's status is pending, so you need to check the trace. 

```ruby
clock.traces.first
=> #<Syncano::Resources::CodeBoxTrace duration: 526, executed_at: Thu, 30 Apr 2015 05:25:14 +0000, id: 1, result: "2015-04-30 05:25:14 +0000", status: "success">
```

The run method is asynchronous and returns immediately. You should use this to
run codeboxes when you don't care about results at this very moment. If you 
want to run the codebox and get results in one call, you should use webhooks.

# Webhooks 

You can use webhooks to run codeboxes synchronously. Webhooks can be either 
public or private. You have to provide your API key when calling private ones, 
public are public, you can call them with curl, connect with third party
services,  etc. Ruby:


```ruby
webhook = @instance.webhooks.create slug: 'clock-webhook', codebox: clock.primary_key, public: true
#=> #<Syncano::Resources::Webhook codebox: 1, public: true, public_link: "a20b0ae122b53b2f2c445f6a7a202b274c3631ad", slug: "clock-webhook">

webhook.run['result']
#=> "2015-04-30 05:51:45 +0000"
```

and curl

```bash
$ curl "https://api.syncano.rocks/v1/instances//af248d3e8b92e6e7aaa42dfc41de80c66c90d620cbe3fcd19/webhooks/p/a20b0ae122b53b2f2c445f6a7a202b274c3631ad/"
{"status": "success", "duration": 270, "result": "2015-04-30 06:11:08 +0000", "executed_at": "2015-04-30T06:11:08.607389Z"}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
