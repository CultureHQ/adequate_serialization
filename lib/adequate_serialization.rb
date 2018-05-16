require 'adequate_serialization/attribute'
require 'adequate_serialization/options'
require 'adequate_serialization/serializable'
require 'adequate_serialization/serializer'
require 'adequate_serialization/steps'
require 'adequate_serialization/version'

require 'adequate_serialization/steps/passthrough_step'
require 'adequate_serialization/steps/rails_cache_step'
require 'adequate_serialization/steps/serialize_step'

module AdequateSerialization
  class << self
    def dump(value)
      return value if value.is_a?(Hash)
      value.respond_to?(:serialized) ? value.serialized : value
    end

    def prepend(step)
      @steps ||= step.new(steps)
    end

    def steps
      @steps ||= Steps::SerializeStep.new
    end
  end
end
