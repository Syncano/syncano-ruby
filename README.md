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

#groups 


# Working with instances

In order to do anything with Syncano, you have to create an instances. Choose a
globally unique name and call:

```ruby
instances = syncano.instances.create name: 'my_instances_name'       
```

# Working with classes and objects

In order to save objects in Syncano, first you need to create a class. A class
defines objects' attributes in class' schema. 



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
