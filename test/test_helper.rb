# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'adequate_serialization'

require 'rails/all'
require 'sqlite3'
require 'minitest/autorun'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# This because AR::Migration outputs to standard out and there's no way to shut
# it off short of redefining $stdout. Lame. I just want green dots.
ActiveRecord::Migration.prepend(Module.new { def say(*); end })

Rails.cache = ActiveSupport::Cache::MemoryStore.new

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :title
    t.timestamps
  end

  create_table :comments, force: true do |t|
    t.references :post
    t.string :body
    t.timestamps
  end
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include AdequateSerialization::Serializable
end

class Post < ApplicationRecord
  has_many :comments
end

class Comment < ApplicationRecord
  belongs_to :post
end

class PostSerializer < AdequateSerialization::Serializer
  attribute :id, :title, :created_at
  attribute :comments, optional: true
end

class CommentSerializer < AdequateSerialization::Serializer
  attribute :id, :body
  attribute :post, optional: true
end

Post.create!(title: 'Adequate Serialization') do |post|
  post.comments.build([{ body: 'Great post!' }, { body: 'This is great!' }])
end

Post.create!(title: 'Other Serialization Techniques')

Post.create!(title: 'Lame Serialization') do |post|
  post.comments.build(body: 'These are super lame.')
end

class User
  include AdequateSerialization::Serializable

  attr_reader :id, :name, :title

  def initialize(id: 1, name: 'Clark Kent', title: 'Superman')
    @id = id
    @name = name
    @title = title
  end

  def cache_key
    "user/#{id}"
  end

  def ==(other)
    other.is_a?(User) && id == other.id
  end
end

class UserSerializer < AdequateSerialization::Serializer
  attribute :id, :name
  attribute :title, optional: true
end
