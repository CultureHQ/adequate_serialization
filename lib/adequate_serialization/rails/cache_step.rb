# frozen_string_literal: true

module AdequateSerialization
  module Rails
    module CacheKey
      def self.cacheable?(object)
        if object.class < ActiveRecord::Base
          object.has_attribute?(:updated_at)
        else
          object.respond_to?(:cache_key)
        end
      end

      def self.for(object, includes = [])
        includes.empty? ? object : [object, *includes]
      end
    end

    class CacheStep < Steps::Step
      def apply(response)
        object = response.object
        opts = response.opts

        if opts.options[:multi_caching] || !CacheKey.cacheable?(object)
          return apply_next(response)
        end

        ::Rails.cache.fetch(CacheKey.for(object, opts.includes)) do
          apply_next(response)
        end
      end
    end

    AdequateSerialization.prepend(CacheStep)
  end
end
