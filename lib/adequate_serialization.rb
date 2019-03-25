# frozen_string_literal: true

require 'adequate_serialization/attribute'
require 'adequate_serialization/decorator'
require 'adequate_serialization/inline_serializer'
require 'adequate_serialization/options'
require 'adequate_serialization/serializable'
require 'adequate_serialization/serializer'
require 'adequate_serialization/steps'
require 'adequate_serialization/version'

require 'adequate_serialization/steps/step'
require 'adequate_serialization/steps/serialize_step'

if defined?(::Rails)
  require 'adequate_serialization/rails/cache_step'
  require 'adequate_serialization/rails/relation_serializer'
  ActiveRecord::Base.include(AdequateSerialization::Serializable)
end
