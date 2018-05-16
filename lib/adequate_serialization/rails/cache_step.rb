# frozen_string_literal: true

module AdequateSerialization
  module Rails
    class CacheStep < Steps::PassthroughStep
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
  end
end
