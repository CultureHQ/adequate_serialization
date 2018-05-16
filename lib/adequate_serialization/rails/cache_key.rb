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
  end
end
