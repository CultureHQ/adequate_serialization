# frozen_string_literal: true

module AdequateSerialization
  module Attribute
    class Simple
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def serialize_to(response, model, _includes)
        response[name] = Attribute.dump(model.public_send(name))
      end
    end

    class Synthesized
      attr_reader :name, :block

      def initialize(name, &block)
        @name = name
        @block = block
      end

      def serialize_to(response, model, _includes)
        response[name] = Attribute.dump(block.call(model))
      end
    end

    class IfCondition
      attr_reader :attribute, :condition

      def initialize(attribute, condition)
        @attribute = attribute
        @condition = condition
      end

      def serialize_to(response, model, includes)
        return unless model.public_send(condition)
        attribute.serialize_to(response, model, includes)
      end
    end

    class UnlessCondition
      attr_reader :attribute, :condition

      def initialize(attribute, condition)
        @attribute = attribute
        @condition = condition
      end

      def serialize_to(response, model, includes)
        return if model.public_send(condition)
        attribute.serialize_to(response, model, includes)
      end
    end

    class Optional
      attr_reader :attribute

      def initialize(attribute)
        @attribute = attribute
      end

      def serialize_to(response, model, includes)
        return unless includes.include?(attribute.name)
        attribute.serialize_to(response, model, includes)
      end
    end

    class Config
      attr_reader :attribute, :options

      def initialize(attribute, options)
        @attribute = attribute
        @options = options
      end

      def to_attribute
        nested = nested_attribute_from(attribute, options)
        nested ? Config.new(nested, options).to_attribute : attribute
      end

      private

      def nested_attribute_from(attribute, options)
        if options.delete(:optional)
          Optional.new(attribute)
        elsif if_option
          IfCondition.new(attribute, if_option)
        elsif unless_option
          UnlessCondition.new(attribute, unless_option)
        end
      end

      def if_option
        @if_option ||= options.delete(:if)
      end

      def unless_option
        @unless_option ||= options.delete(:unless)
      end
    end

    class << self
      def dump(value)
        return value if value.is_a?(Hash)
        value.respond_to?(:as_json) ? value.as_json : value
      end

      def from(name, options = {}, &block)
        attribute =
          if block
            Synthesized.new(name, &block)
          else
            Simple.new(name)
          end

        Config.new(attribute, options).to_attribute
      end
    end
  end
end
