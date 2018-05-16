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
      attr_reader :object, :opts

      def initialize(object, opts = {})
        @object = object
        @opts = opts
      end

      def mutate(new_object)
        self.class.new(new_object, opts)
      end
    end
  end

  class << self
    def prepend(step)
      @steps = step.new(steps)
    end

    def steps
      @steps ||= Steps::SerializeStep.new
    end
  end
end
