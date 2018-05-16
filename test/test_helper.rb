# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'adequate_serialization'

require 'minitest/autorun'

class User
  include AdequateSerialization::Serializable

  attr_reader :id, :name, :title

  def initialize(id: 1, name: 'Clark Kent', title: 'Superman')
    @id = id
    @name = name
    @title = title
  end
end

class UserSerializer < AdequateSerialization::Serializer
  attribute :id, :name
  attribute :title, optional: true
end
