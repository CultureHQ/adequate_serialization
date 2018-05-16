# frozen_string_literal: true

module AdequateSerialization
  class RelationSerializer
    attr_reader :relation

    def initialize(relation)
      @relation = relation
    end

    def serialized(*opts)
      return [] if relation.empty?

      options = Options.from(*opts, multi_caching: true)
      cache_keys = relation.map { |record| options.cache_key_for(record) }

      results_for(cache_keys, options)
    end

    private

    def fetch_multi_for(cache_keys, options)
      Rails.cache.fetch_multi(*cache_keys) do |(record, *)|
        record.class.serializer.serialize(record, options)
      end
    end

    def results_for(cache_keys, options)
      decorator = Decorator.from(opts.attachments)
      results = fetch_multi_for(cache_keys, options)

      cache_keys.map do |cache_key|
        decorator.decorate(results[cache_key])
      end
    end
  end
end
