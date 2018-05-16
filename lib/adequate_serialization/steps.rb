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
  end
end
