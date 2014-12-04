# Syncano

Syncano ruby gem provides communication with Syncano ([www.syncano.com](http://www.syncano.com)) via HTTPS RESTful interface and TCP sockets.

The full source code can be found on [Github](https://github.com/Syncano/syncano-ruby) - feel free to browse or contribute.

Click here to learn more about [Syncano](http://www.syncano.com) or [create an account](https://login.syncano.com/sign_up)!

## Installation

Add this line to your application's Gemfile:

    gem 'syncano', '~> 3.1'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install syncano -v 3.1.3
    
At the end generate initializer with api key and api instance name:

    $ rails g syncano:install

Initializer is not obligatory - you can provide both parameters directly in the client's constructor.

## Usage

### Clients

There are two different class of clients. One for JSON RPC interface and one for socket connections with Sync Server. You can use both in quite similar way:

```ruby
client = Syncano.client

client = Syncano.sync_client
```
    
You can provide specific api credentials when you are initializing your client:

```ruby
client = Syncano.client(api_key: 'api key', instance_name: 'instance name')

client = Syncano.sync_client(api_key: 'api key', instance_name: 'instance name')
```

Sync client has some additional features like:

* managing connections
```ruby
client.connect
client.reconnect
client.disconnect
```
* managing callbacks for handling notifications (it is described later in this document)

#### User api key

If you want to use an user api key, you have to pass auth key or username and password to the client's constructor.

```ruby
client = Syncano.client(api_key: 'api key', instance_name: 'instance name', auth_key: 'auth key')
```

```ruby
client = Syncano.client(api_key: 'api key', instance_name: 'instance name', username: 'username', password: 'password')
```

### Resources

Syncano gem utilizes an ActiveRecord pattern for managing resources. You can use it in similar way with both type of clients.

Below is a list of standard methods implemented in resources.

* objects.all(parameters)
* objects.count(parameters)
* objects.first(parameters)
* objects.last(parameters)
* objects.find(id)
* objects.new(attributes)
* objects.create(attributes)
* object.update(attributes)
* object.save
* object.destroy

Some of resources do not implement all standard methods and others have some custom methods, ie. data_object.copy.

Every resource has attributes which can be accessed as a hash ie.:

* object[:attribute]
* object[:attribute] = 'value'
* object.attributes = { attribute: 'value' }

Below is a list of all implemented resources with information about what methods are implemented and usage examples.

#### Project

Implements all standard methods and following custom:

* project.authorize(api_key_id, permission)

##### Examples

* Getting all projects

```ruby
Syncano.projects.all
```

* Creating a project

```ruby
Syncano.projects.create(name: 'Project name')
```

* Updating a project

```ruby
project[:description] = 'Lorem ipsum'
project.save
```

* Authorizing user api key with read permission

```ruby
project.authorize(api_key_id, 'read_data')
```

#### Collection

Implements all standard methods and following custom:

* collections.find_by_key(collection_key)
* collection.activate
* collection.deactivate
* collection.add_tag(tag, weight, remove_others)
* collection.delete_tag(tag)
* collection.authorize(api_key_id, permission)

##### Examples

* Getting all

```ruby
project.collections.all
```

* Finding by key

```ruby
project.collections.find_by_key(collection_key)
```

* Activating

```ruby
collection.activate
```

* Adding tags

```ruby
collection1.add_tags(['tag1', 'tag2'], 3)
collection2.add_tags('tag3', 1, true)
```

#### Folder

Implements all standard methods and following custom:

* folders.find_by_name(folder_name)
* folder.authorize(api_key_id, permission)

Find method uses folder name as a key.

##### Examples

* Getting one

```ruby
collection.folders.find(folder_name)
collection.folders.find_by_name(folder_name)
```

#### Data object

Implements all standard methods and following custom:

* data_objects.find_by_key(data_object_key)
* data_objects.move(data_object_ids, new_folder, new_state)
* data_object.move(new_folder, new_state)
* data_objects.copy(data_object_ids)
* data_object.copy
* data_object.add_parent(parent_id, remove_other)
* data_object.remove_parent(parent_id)
* data_object.add_child(parent_id, remove_other)
* data_object.remove_child(parent_id)

##### Examples

* Moving data object to the new folder

```ruby
data_object.move('new_folder')
```

* Copying two data objects

```ruby
collection.data_objects.copy([112, 3871])
```

* Adding parent to the data object

```ruby
data_object.add_parent(parent_object_id, true)
```

#### Admin

Implements all standard methods and following custom:

* admin.find_by_email(email)

#### Api key

Implements all standard methods.

#### Role

Implements only following standard methods:

* role.all
* role.first
* role.last
* role.count

#### User

Implements all standard methods.

### Batch requests

It is possible to make batch requests to the JSON RPC endpoint. You do not have to care about batch requests limits specified in the Syncano api docs. This library will care about queuing for you.

```ruby
client = Syncano.client
responses = client.batch do |queue|
  queue << collection.batch.save
  queue << collection.data_objects.batch.create(title: 'Lorem ipsum')
  queue.add(data_object.batch.destroy)
end
```

There is no difference between "queue.add" and "queue <<" methods.

In the above example variable responses will contain three Syncano::Response objects.
Remember that batch responses do not change objects used in batch requests. If you want to see changes you have to reload them:

```ruby
collection.reload
```

### Notifications

Main advantage of using Sync Server are real time notifications. This concept is well described in the Syncano api documentation.

#### Subscriptions

Before you will receive any notification, you have to subscribe to some project or collection:

```ruby
client = Syncano.sync_client
project = client.project.find(project_id)
project.subscribe
```

If you want to stop receiving notifications, you have to unsubscribe:
```ruby
project.unsubscribe
```

You can also list all active subscriptions:
```ruby
client.subscriptions.all
```

#### Handling notifications

Notifications are handled by callbacks passed to the sync client:

```ruby
client.append_callback(:callback_name) do |notification|
  p "We have received a new notification #{notification.inspect}! Yaaay!"
end
```

Callbacks form a queue. You can add new callback to the end of the queue (like above) or to the beginning:

```ruby
client.prepend_callback(:callback_name) do |notification|
  p "We have received a new notification #{notification.inspect}! Yaaay!"
end
```

To delete callback from the queue just call remove_callback method:
 
```ruby
client.remove_callback(:callback_name)
```

To list notifications ie. after connection use all method:

```ruby
client.notifications.all
```

#### Sending notifications

To send notification just create new notification object:

```ruby
client.notifications.create(key: 'value')
```

You can also pass additional attributes specified for api 'notification.send' method:

```ruby
client.notifications.create(key: 'value', api_client_id: 512)
```

### Errors and exceptions

This library does not implement any validations. All errors from the api will cause throwing an exception.
It is thought that user will create his own validation mechanisms specific not only for restrictions imposed by the Syncano, but also for his own logic.
It can be compared to the exceptions after violating constraints in the MySQL database.

### Integration with Ruby on Rails

Syncano gem provides handy class for implementing model with ActiveRecord pattern. See example below: 

```ruby
class Category < Syncano::ActiveRecord::Base
  has_many :articles
  
  attribute :name, type: String
  validates :name, presence: true  
end

class Article < Syncano::ActiveRecord::Base
  belongs_to :category
  
  attribute :title, type: String
  attribute :text, type: String
  attribute :promoted, type: Integer, filterable: :data1
  validates :title, presence: true
  validates :text, presence: true
  
  scope :promoted, -> { where('promoted = ?', 1) }
  
  before_save :sanitize_content
  
  private
  
  def sanitize_content
    self.title = Sanitize.clean(title)
    self.text = Sanitize.clean(text)
  end
end
```

#### Attributes

As you can see above every attribute has to be declared with a type. Every ActiveRecord class has also three standard attributes:
- :id, type: Integer
- :created_at, type: DateTime
- :updated_at, type: DateTime

There can be up to three filterable attributes (mapped to the Syncano data1, data2, data3 attributes), which can be used in where and order clauses. They always should have Integer type.
   
Attributes can be validated like in standard ActiveRecord.

#### Scopes and query building

You can sort and filter by filterable attributes:

```ruby
where('attribute1 > ? AND attribute2 <= ?', 0, 30).order('attribute3 ASC').where('attribute 2 > ?', 5)
```

As you can see methods can be chained. 

#### Callbacks

There are available ten different callbacks fired in the following sequence:

1. before_validation
2. after_validation
3. before_save
4. before_create / before_update
5. after_create / after_save
6. after_save

1. before_destroy
2. after_destroy

#### Associations

There are three types of relations (belongs_to, has_one, has_many) which are based on Syncano parent - child mechanism.

##### belongs_to :category

Adds following methods:

```ruby
self.category
self.category = Category.first
self.category_id
self.category_id = Category.first.id
```

Remember to always declare belongs_to association! It creates proper attribute in model.

##### has_one :article

```ruby
self.article
self.article = Article.first # this method updates article object
self.build_article(article_attributes)
self.create_article(article_attributes)
```

##### has_many :articles

```ruby
self.articles
self.articles = Article.first(5) # this method updates each article object
self.articles << Article.first # this method updates article object
self.articles.build(article_attributes)
self.articles.create(article_attributes)
```

You can also call scope builder methods on has_many collection:

```ruby
self.articles.promoted.all
```

#### Other useful methods in examples

```ruby
Article.promoted.find(id)
Article.where('promoted = ?', 0).count
Article.since(min_id).before(max_id)
Article.since(Time.now - 10.days)
```

For all methods please see reference for Syncano::ActiveRecord::Base class.

#### Collection and folders

Classes which inherit from Syncano::ActiveRecord::Base needs a collection and a folders in Syncano. 

Collection can be configured as constant in initializer:
 
```ruby
SYNCANO_ACTIVERECORD_COLLECTION = Syncano.client.project.first.collection.first
```

or it can be overwritten in selected model:

```ruby
class Article < Syncano::ActiveRecord::Base

  private
  
  def self.collection
    Syncano.client.project.first.collection.first
  end
end
```

Folders are used as classes - each model as his own folder (ie. Articles). Folder is automatically created and used without any additional configuration, but you can customize convention by overwriting folder_name or folder method:

```ruby
class Article < Syncano::ActiveRecord::Base

  private
  
  def self.folder_name
    'Posts'
  end
  
  def self.folder
    collection.folders.find_by_name(folder_name)
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
