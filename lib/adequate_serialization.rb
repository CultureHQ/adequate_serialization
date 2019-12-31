# frozen_string_literal: true

require 'oj'

module AdequateSerialization
  class Error < StandardError
    def initialize(message)
      super(message.gsub("\n", ' '))
    end
  end

  class << self
    attr_accessor :active_job_queue

    def configure
      yield self
    end
  end

  self.active_job_queue = :default
end

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

if defined?(Rails)
  require 'adequate_serialization/rails/cache_busting'
  require 'adequate_serialization/rails/cache_step'
  require 'adequate_serialization/rails/cache_visualization'
  require 'adequate_serialization/rails/relation_serializer'

  module AdequateSerialization
    Serializer.singleton_class.prepend(CacheBusting)
    ActiveRecord::Base.include(Serializable)
  end

  Oj.optimize_rails
end
