# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'adequate_serialization'

require 'minitest/autorun'

class User
  ID = 1
  NAME = 'Kevin'

  include AdequateSerialization::Serializable

  def id
    ID
  end

  def name
    NAME
  end
end

class UserSerializer < AdequateSerialization::Serializer
  attribute :id, :name
end
