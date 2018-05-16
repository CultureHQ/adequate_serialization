# frozen_string_literal: true

module AdequateSerialization
  module Rails
    class CacheStep < Steps::PassthroughStep
      def apply(response)
        if response.opts.options[:multi_caching] || !cacheable?(response)
          return apply_next(response)
        end

        ::Rails.cache.fetch(cache_key_for(response)) do
          apply_next(response)
        end
      end

      private

      def cache_key_for(response)
        object = response.object
        includes = response.opts.includes

        includes.empty? ? object : [object, *includes]
      end

      def cacheable?(response)
        object = response.object

        if object.class < ActiveRecord::Base
          object.has_attribute?(:updated_at)
        else
          object.respond_to?(:cache_key)
        end
      end
    end
  end
end
