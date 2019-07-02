# frozen_string_literal: true

module AdequateSerialization
  module Rails
    class Visualizer
      using(
        Module.new do
          refine ActiveRecord::Reflection::AbstractReflection do
            def to_dot
              "#{klass.name} -> #{active_record.name} [label=\"#{name}\"];"
            end
          end
        end
      )

      def to_dot
        <<~EODOT
          digraph attributes {
            node [shape = circle];
            #{active_record_reflections.map(&:to_dot).join("\n  ")}
          }
        EODOT
      end

      def to_svg
        svg =
          IO.popen('dot -Tsvg', 'w+') do |f|
            f.write(to_dot)
            f.close_write
            f.readlines
          end

        3.times { svg.shift }
        svg.join.gsub(/(width|height)="[^"]*"/, '')
      end

      def self.to_svg
        new.to_svg
      end

      private

      def active_record_serializers
        ::Rails.application.eager_load!
        base = AdequateSerialization::Serializer

        ObjectSpace.each_object(base.singleton_class).select do |serializer|
          serializer < base && serializer.serializes < ActiveRecord::Base
        end
      end

      def active_record_reflections
        [].tap do |reflections|
          active_record_serializers.each do |serializer|
            serializer.attributes.each do |attribute|
              serializes = serializer.serializes
              reflection = serializes.reflect_on_association(attribute.name)

              next if !reflection || reflection.polymorphic?
              reflections << reflection
            end
          end
        end
      end
    end
  end
end
