# frozen_string_literal: true

module AdequateSerialization
  class Serializer
    class << self
      def attributes
        @attributes ||= []
      end

      def attribute(*names, &block)
        options =
          if names.last.is_a?(Hash)
            names.pop
          else
            {}
          end

        additions =
          names.map! { |name| Attribute.from(name, options.dup, &block) }

        @attributes = attributes + additions
      end
    end

    def serialize(model, opts = Options.null)
      self.class.attributes.each_with_object({}) do |attribute, response|
        attribute.serialize_to(response, model, opts.includes)
      end
    end
  end
end
