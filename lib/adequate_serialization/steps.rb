# frozen_string_literal: true

module AdequateSerialization
  module Steps
    def self.apply(object, *options)
      opts = Options.from(*options)

      response = Response.new(object, opts)
      decorator = Decorator.from(opts.attachments)

      decorator.decorate(AdequateSerialization.steps.apply(response))
    end

    class Response
      attr_reader :object, :opts, :current

      def initialize(object, opts = {}, current = nil)
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
