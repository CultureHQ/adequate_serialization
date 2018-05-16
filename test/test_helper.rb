# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'adequate_serialization'

require 'minitest/autorun'

class User
  NAME = 'Kevin'

  include AdequateSerialization::Serializable

  def name
    NAME
  end
end

class UserSerializer < AdequateSerialization::Serializer
  attribute :name
end
