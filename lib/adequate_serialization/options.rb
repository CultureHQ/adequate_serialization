# frozen_string_literal: true

module AdequateSerialization
  module Options
    class Opts
      attr_reader :includes, :attachments, :options

      def initialize(includes: [], attach: {}, **options)
        @includes = Array(includes)
        @attachments = attach
        @options = options
      end
    end

    def self.from(*opts)
      Opts.new(opts[0] || {})
    end

    def self.null
      Opts.new
    end
  end
end
