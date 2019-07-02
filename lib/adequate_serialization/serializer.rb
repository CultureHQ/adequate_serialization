# frozen_string_literal: true

module AdequateSerialization
  class Serializer
    class ClassNotFoundError < Error
      def initialize(serializer, serializes)
        super(<<~MSG)
          AdequateSerialization was unable to find the associated class to
          serialize for #{serializer}. It expected to find a class named
          #{serializes}. This could mean that it was incorrectly named, or that
          you have yet to create the class that it will serialize.
        MSG
      end
    end

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

      def serializes
        return @serializes if defined?(@serializes)

        class_name = name.gsub(/Serializer\z/, '')

        begin
          @serializes = const_get(class_name)
        rescue NameError
          raise ClassNotFoundError.new(name, class_name)
        end
      end
    end

    def serialize(model, opts = Options.null)
      self.class.attributes.each_with_object({}) do |attribute, response|
        attribute.serialize_to(self, response, model, opts.includes)
      end
    end
  end
end
