# frozen_string_literal: true

require 'oj'

module AdequateSerialization
  class Error < StandardError
    def initialize(message)
      super(message.gsub("\n", ' '))
    end
  end

  class << self
    attr_reader :active_job_queue

    # Configure the queue name that AdequateSerialization will use when
    # enqueuing jobs to bust associated caches.
    def active_job_queue=(queue_name)
      require 'adequate_serialization/rails/cache_refresh'
      CacheRefresh::CacheRefreshJob.queue_name = queue_name
    end

    # Associate one or more caches with an active record such that when the
    # record is updated the associated object caches are also updated.
    def associate_cache(active_record, *association_names)
      require 'adequate_serialization/rails/cache_refresh'

      unless active_record.respond_to?(:associate_cache)
        active_record.extend(CacheRefresh)
      end

      association_names.each do |association_name|
        active_record.associate_cache(association_name)
      end
    end

    # DSL-like block for parity with other Ruby/Rails libraries.
    def configure
      yield self
    end
  end

  @active_job_queue = :default
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
