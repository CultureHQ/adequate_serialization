require 'adequate_serialization/attribute'
require 'adequate_serialization/options'
require 'adequate_serialization/serializable'
require 'adequate_serialization/serializer'
require 'adequate_serialization/steps'
require 'adequate_serialization/version'

module AdequateSerialization
  class << self
    def prepend(step)
      @steps ||= step.new(steps)
    end

    def steps
      @steps ||= Steps::SerializeStep.new
    end
  end
end
