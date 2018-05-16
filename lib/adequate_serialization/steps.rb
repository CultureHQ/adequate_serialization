# frozen_string_literal: true

module AdequateSerialization
  module Steps
    def self.apply(object, *opts)
      response = Response.new(object, Options.from(*opts))
      AdequateSerialization.steps.apply(response)
    end

    class Response
      attr_reader :object, :opts, :current

      def initialize(object, opts, current = nil)
        @object = object
        @opts = opts
        @current = current
      end

      def mutate(current)
        self.class.new(object, opts, current)
      end
    end

    class BaseStep
      attr_reader :next_step

      def initialize(next_step = LastStep.new)
        @next_step = next_step
      end

      private

      def apply_next(response)
        next_step.apply(response)
      end
    end

    class LastStep
      def apply(response)
        response.current
      end
    end

    class SerializeStep < BaseStep
      def apply(response)
        object = response.object
        serialized = object.class.serializer.serialize(object, response.opts)

        apply_next(response.mutate(serialized))
      end
    end

    class RailsCacheStep < BaseStep
      def apply(response)
        if response.opts.multi_caching? || !cacheable?(response)
          return apply_next(response)
        end

        Rails.cache.fetch(cache_key_for(response)) do
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
