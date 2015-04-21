# Syncano 4.0 ruby gem


## Installation

Using gems:

```
$ gem install syncano --pre
```

## First steps

After installation, you have to set a path for api root for syncano.

If you want to use staging, export:

```
$ export API_ROOT=https://v4.hydraengine.com
```

If you're less adventurous, use our production api servers:

```
$ export=API_ROOT=https://api.syncano.io

```

Ok, now we can start coding!

```
# import syncano
require 'syncano'

# set your api key
api_key='your-api-key'

# connect to syncano
connection = Syncano.connect(api_key: api_key)

# use syncano to do cool stuff - here printing names of all your instances
connection.instances.all.each { |instance| puts instance }
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
