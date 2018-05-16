# frozen_string_literal: true

module AdequateSerialization
  module Steps
    def self.apply(object, *opts)
      options = Options.from(*opts)
      response = Response.new(object, options)

      AdequateSerialization.steps.apply(response).tap do |serialized|
        options.attachments.each do |name, attachment|
          serialized[name] =
            AdequateSerialization.dump(attachment[serialized[:id]])
        end
      end
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
