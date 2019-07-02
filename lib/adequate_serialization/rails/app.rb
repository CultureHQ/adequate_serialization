# frozen_string_literal: true

module AdequateSerialization
  module Rails
    module App
      class Index
        STATIC = File.expand_path('static', __dir__)
        FILES =
          Dir[File.join(STATIC, '*')].map { |path| "/#{File.basename(path)}" }

        attr_reader :app, :server

        def initialize(app)
          @app = app
          @server = Rack::File.new(STATIC)
        end

        def call(env)
          if env[Rack::PATH_INFO] == '/'
            render_index(env)
          elsif FILES.include?(env[Rack::PATH_INFO])
            server.call(env)
          else
            app.call(env)
          end
        end

        private

        def render_index(env)
          content = File.read(File.join(STATIC, 'index.html.erb'))
          locals = {
            svg: Visualizer.to_svg,
            script_name: env[Rack::SCRIPT_NAME]
          }

          result = ERB.new(content).result_with_hash(locals)
          [200, { 'Content-Type' => 'text/html' }, [result]]
        end
      end

      class << self
        def middlewares
          @middlewares ||= []
        end

        def use(*args, &block)
          middlewares << [args, block]
        end

        def call(env)
          app.call(env)
        end

        private

        def app
          @app ||= build_app
        end

        def build_app
          configurations = middlewares

          Rack::Builder.new do
            configurations.each { |middleware, block| use(*middleware, &block) }
            use Index

            run lambda { |env|
              [404, { 'Content-Type' => 'text/plain' }, ['Not Found']]
            }
          end
        end
      end
    end
  end
end
