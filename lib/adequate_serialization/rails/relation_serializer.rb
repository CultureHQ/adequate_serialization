# frozen_string_literal: true

module AdequateSerialization
  module Rails
    class RelationSerializer
      attr_reader :relation

      def initialize(relation)
        @relation = relation
      end

      def serialized(*options)
        return [] if relation.empty?

        opts = Options.from(*options, multi_caching: true)
        decorator = Decorator.from(opts.attachments)

        response_for(opts, decorator)
      end

      private

      def response_for(opts, decorator)
        cache_keys = cache_keys_for(opts)

        if cache_keys
          cacheable_response_for(opts, decorator, cache_keys)
        else
          uncacheable_response_for(opts, decorator)
        end
      end

      def cache_keys_for(opts)
        relation.map do |record|
          return nil unless CacheKey.cacheable?(record)
          CacheKey.for(record, opts.includes)
        end
      end

      def cacheable_response_for(opts, decorator, cache_keys)
        results =
          ::Rails.cache.fetch_multi(*cache_keys) do |(record, *)|
            serialize(record, opts)
          end

        cache_keys.map do |cache_key|
          decorator.decorate(results[cache_key])
        end
      end

      def uncacheable_response_for(opts, decorator)
        relation.map do |record|
          decorator.decorate(serialize(record, opts))
        end
      end

      def serialize(record, opts)
        record.class.serializer.serialize(record, opts)
      end
    end
  end
end
