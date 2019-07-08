# frozen_string_literal: true

module AdequateSerialization
  module Rails
    class CacheVisualization
      using(
        Module.new do
          refine ActiveRecord::Reflection::AbstractReflection do
            def to_dot
              "#{klass.name} -> #{active_record.name} [label=\"#{name}\"];"
            end
          end
        end
      )

      STATIC = File.expand_path('static', __dir__)
      FILES = %w[/favicon.ico].freeze

      attr_reader :app, :server

      def initialize
        @server = Rack::File.new(STATIC)
      end

      def call(env)
        if env[Rack::PATH_INFO] == '/'
          render_index(env)
        elsif FILES.include?(env[Rack::PATH_INFO])
          server.call(env)
        else
          [404, { 'Content-Type' => 'text/plain' }, ['Not Found']]
        end
      end

      def self.call(env)
        (@app ||= new).call(env)
      end

      private

      def to_dot
        <<~EODOT
          digraph attributes {
            node [shape = circle];
            #{reflections.map(&:to_dot).join("\n  ")}
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
        svg.join.gsub(/(height|width)="[^"]*"/, '')
      end

      def render_index(env)
        content = File.read(File.join(STATIC, 'index.html.erb'))
        locals = { svg: to_svg, script_name: env[Rack::SCRIPT_NAME] }

        result = ERB.new(content).result_with_hash(locals)
        [200, { 'Content-Type' => 'text/html' }, [result]]
      end

      def serializers
        ::Rails.application.eager_load!
        base = Serializer

        ObjectSpace.each_object(base.singleton_class).select do |serializer|
          serializer < base &&
            serializer.name &&
            serializer.serializes < ActiveRecord::Base
        rescue AdequateSerialization::Serializer::ClassNotFoundError
          false
        end
      end

      def reflections
        serializers.each_with_object([]) do |serializer, selected|
          serializer.attributes.each do |attribute|
            serializes = serializer.serializes
            reflection = serializes.reflect_on_association(attribute.name)

            next if !reflection || reflection.polymorphic?

            selected << reflection
          end
        end
      end
    end
  end
end
