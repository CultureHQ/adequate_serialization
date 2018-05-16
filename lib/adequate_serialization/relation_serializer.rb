# frozen_string_literal: true

module AdequateSerialization
  class RelationSerializer < SimpleDelegator
    class NullDecorator
      def decorate(result)
        result
      end
    end

    class AttachmentDecorator < TinyStruct.new(:attachments)
      def decorate(result)
        attachments.each do |name, attachment|
          result[name] = attachment[result[:id]]
        end

        result
      end
    end

    def as_json(*options)
      return [] if empty?

      opts = Serializer::Options.from(*options, multi_caching: true)
      cache_keys = map { |record| opts.cache_key_for(record) }

      results_for(cache_keys, opts)
    end

    private

    def fetch_multi_for(cache_keys, opts)
      Rails.cache.fetch_multi(*cache_keys) do |(record, *)|
        record.class.serializer.serialize(record, opts)
      end
    end

    def decorator_for(opts)
      attachments = opts.attachments

      if attachments.empty?
        NullDecorator.new
      else
        AttachmentDecorator.new(attachments)
      end
    end

    def results_for(cache_keys, opts)
      decorator = decorator_for(opts)
      results = fetch_multi_for(cache_keys, opts)

      cache_keys.map do |cache_key|
        decorator.decorate(results[cache_key])
      end
    end
  end
end
