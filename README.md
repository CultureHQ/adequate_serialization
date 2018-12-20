# AdequateSerialization

[![Gem Version](https://img.shields.io/gem/v/adequate_serialization.svg)](https://github.com/CultureHQ/adeqaute_serialization)

Serializes objects adequately. `AdequateSerialization` allows you to define serializers that will convert your objects into simple hashes that are suitable for variable purposes such as caching or using in an HTTP response. It stems from the simple idea of giving slightly more control over the `as_json` method that gets called when objects are serialized using Rails' default controller serialization.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'adequate_serialization'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install adequate_serialization

## Usage

First, include `AdequateSerialization::Serializable` in any object that you want to be able to serialize. Then, define a serializer matching the name of that object, postfixed with `"Serializer"`. Use the `AdequateSerialization` DSL to define the attributes that are available to the serializer. You can then call `as_json` on any instance of that object to get the resultant hash. Below is an example:

```ruby
class User
  include AdequateSerialization::Serializable

  attr_reader :id, :name, :title

  ...
end

class UserSerializer < AdequateSerialization::Serializer
  attribute :id, :name, :title
end

User.new(id: 1, name: 'Clark Kent', title: 'Superman').as_json
# => {:id=>1, :name=>"Clark Kent", :title=>"Superman"}
```

### Defining attributes

The `AdequateSerialization::Serializer` DSL is just the one `attribute` method. You can pass as many names as you want, and each attribute will become a key in the resultant serialized hash. If you need to build a "synthesized" attribute (one that is defined in the serializer), you can do so with a block that receives the object as an argument, as in:

```ruby
class UserSerializer < AdequateSerialization::Serializer
  attribute :double_name do |user|
    user.name * 2
  end
end
```

There are also a couple of options that you can pass to the `attribute` method as the last argument that modify the serializer's behavior, listed below.

#### :if

If you pass an `:if` condition, that method will be called on the serializable object to determine whether or not that attribute should be included in the resultant hash, as in:

```ruby
class UserSerializer < AdequateSerialization::Serializer
  attribute :title, if: :manager?
end

user = User.new(...)
user.as_json
# => {:id=>1, :name=>"Clark Kent"}

user.update(manager: true)
user.as_json
# => {:id=>1, :name=>"Clark Kent", :title=>"Superman"}
```

#### :unless

This is the same as the `:if` option, but will result in the opposite behavior (the attribute will be present if the predicate is not met).

#### :optional

There are times when you want to include an attribute that you normally wouldn't. For example, if you have both `Post` and `Comment` objects, normally you wouldn't include the `post` attribute on the child `comment` objects. However, if you're serializing just the comment, it might be useful to have the `post` attached. In this case, you could mark the attribute as `optional` and it would only be included if it was listed in the `:includes` option passed to the `as_json` method, as in:

```ruby
class PostSerializer < AdequateSerialization::Serializer
  attribute :id, :title, :body
  attribute :comments, optional: true
end

class CommentSerializer < AdequateSerialization::Serializer
  attribute :id, :body
  attribute :post, optional: true
end

comment = Comment.new(...)
comment.as_json
# => {:id=>1, :body=>"This is a great gem!"}

comment.as_json(includes: :post)
# => {:id=>1, :body=>"This is a great gem!", :post=>{:id=>1, :title=>"Introducing Adequate Serializer", :body=>"This is adequate serializer."}}
```

The `includes` key can take either a single name or an array of names.

### Attaching objects

There are times where it's more performant to serialize the objects using normal serialization and to attach an additional attribute later. For instance, you could serialize all of the posts and then attach whether or not a user had upvoted them. In that case, there's a special syntax that looks like the below:

```ruby
upvotes =
  User.upvotes.each_with_object({}) do |post, votes|
    votes[post.id] = true
  end
# => {1=>true}

Post.all.map(&:as_json)
# => [{:id=>1}, {:id=>2}]

posts = Post.all.map { |post| post.as_json(attach: { upvoted: upvotes }) }
# => [{:id=>1, :upvoted=>true}, {:id=>2, :upvoted=>false}]
```

This relies on the objects to which you are attaching having an `id` attribute and the attachable hash being an index of `id` pointing to the attribute value.

### Usage with Rails

To get `AdequateSerializer` working with Rails, you can call `AdequateSerializion.hook_into_rails!` in an initializer. This will do three things:

1. Introduce caching behavior so that when serializing objects they will by default be stored in the Rails cache.
1. Include `AdequateSerializer::Serializable` in `ActiveRecord::Base` so that all of your models will be serializable.
2. Overwrite `ActiveRecord::Relation`'s `as_json` method to use the `AdequateSerializer::Rails::RelationSerializer` object, which by default will use the `Rails.cache.fetch_multi` method in order to more efficiently serialize all of the records in the relation.

You can still use plain objects to be serialized, and if you want to take advantage of the caching behavior, you can define a `cache_key` method on the objects that you're serializing. This will cause `AdequateSerialization` to start putting them into the Rails cache.

The result is that you can now this in your controllers:

```ruby
class UsersController
  def show
    user = User.find(params[:id])

    render json: { user: user }
  end
end
```

and the response will be the serialized user. You can pass additional options that will get forwarded on to the serializer as well, as in:

```ruby
class UsersController
  def show
    user = User.find(params[:id])

    render json: { user: user }, includes: :title
  end
end
```

and the result will now contain the `title` attribute (provided it was configured as an optional attribute). All options that previously were passed in to the `as_json` method get forwarded appropriately.

### Advanced

The serialization process happens through a series of `AdequateSerialization::Steps`. The caching behavior mentioned in the `Usage with Rails` section is one such step that gets introduced. You can introduce more yourself like so:

```ruby
class LoggingStep < AdequateSerialization::Steps::PassthroughStep
  def apply(response)
    Logger.log("#{response.object} is being serialized with #{response.opts} options")
    apply_next(response)
  end
end

AdequateSerialization.prepend(LoggingStep)
```

This will cause this object to be placed into the list of steps taken to serialize objects, and can be used for much more powerful and advanced workflows.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CultureHQ/adequate_serialization.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
