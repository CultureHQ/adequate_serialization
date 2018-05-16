# frozen_string_literal: true

module AdequateSerialization
  module Serializable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def serializer
        @serializer ||= const_get("#{name}Serializer").new
      end
    end

    def as_json(*opts)
      opts = Serializer::Opts.from(*opts)

      serialized_for(opts).tap do |serialized|
        opts.attachments.each do |name, attachment|
          serialized[name] = attachment[serialized[:id]].as_json
        end
      end
    end

    private

    def serialized_for(opts)
      with_caching(opts) do
        self.class.serializer.serialize(self, opts)
      end
    end

    def cacheable?
      if self.class < ActiveRecord::Base
        has_attribute?(:updated_at)
      else
        respond_to?(:cache_key)
      end
    end

    def with_caching(opts)
      if !opts.multi_caching? && cacheable?
        Rails.cache.fetch(opts.cache_key_for(self)) do
          yield
        end
      else
        yield
      end
    end
  end
end
