module AdequateSerialization
  module Opts
    class SerializationOpts
      attr_reader :includes, :attachments, :options

      def initialize(includes: [], attach: {}, multi_caching: nil, **options)
        @includes = Array(includes)
        @attachments = attach
        @multi_caching = multi_caching
        @options = options
      end

      def multi_caching?
        @multi_caching
      end

      def cache_key_for(record)
        includes.empty? ? record : [record, *includes]
      end
    end

    class NullOpts
      def includes
        []
      end
    end

    def self.from(*opts)
      SerializationOpts.new(**(opts[0] || {}))
    end

    def self.null
      NullOpts.new
    end
  end
end
