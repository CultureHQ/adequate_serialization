# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] = 'test'

require 'rails'
require 'active_job/railtie'
require 'active_record/railtie'
require 'global_id/identification'

require 'sqlite3'
require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'adequate_serialization'

AdequateSerialization.configure do |config|
  config.active_job_queue = :low
end

class AdequateSerializationApplication < Rails::Application
  config.logger = Logger.new('/dev/null')
  config.cache_store = :memory_store
  config.eager_load = false

  def config.database_configuration
    { 'test' => { 'adapter' => 'sqlite3', 'database' => ':memory:' } }
  end

  initialize!
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Tag < ApplicationRecord
  connection.create_table :tags, force: true do |t|
    t.string :name
    t.timestamps
  end

  has_many :post_tags
  has_many :posts, through: :post_tags, inverse_of: :tags
end

class PostTag < ApplicationRecord
  connection.create_table :post_tags, force: true do |t|
    t.references :post
    t.references :tag
    t.timestamps
  end

  belongs_to :post
  belongs_to :tag
end

class Comment < ApplicationRecord
  connection.create_table :comments, force: true do |t|
    t.references :post
    t.string :body
    t.timestamps
  end

  belongs_to :post, touch: true, inverse_of: :comments
end

class Post < ApplicationRecord
  connection.create_table :posts, force: true do |t|
    t.string :title
    t.timestamps
  end

  has_many :comments
  has_many :post_tags
  has_many :tags, through: :post_tags, inverse_of: :posts

  create!(title: 'Adequate Serialization') do |post|
    post.comments.build([{ body: 'Great post!' }, { body: 'This is great!' }])
    post.tags.build(name: 'Great')
  end

  create!(title: 'Other Serialization Techniques')

  create!(title: 'Lame Serialization') do |post|
    post.comments.build(body: 'These are super lame.')
  end
end

class PostSerializer < AdequateSerialization::Serializer
  attribute :id, :title, :created_at
  attribute :image, :comments, :tags, optional: true
end

class CommentSerializer < AdequateSerialization::Serializer
  attribute :id, :body
  attribute :post, optional: true
end

class TagSerializer < AdequateSerialization::Serializer
  attribute :id, :name
end

class User
  include AdequateSerialization.inline {
    attribute :id, :name
    attribute :title, optional: true
  }

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
