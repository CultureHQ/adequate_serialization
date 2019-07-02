# frozen_string_literal: true

require 'adequate_serialization/rails/visualizer'

module AdequateSerialization
  module Rails
    module App
      # An optional middleware that will get loaded if faye/websocket has been
      # required.
      class Socket
        KEEPALIVE = 15

        attr_reader :app, :clients

        def initialize(app)
          @app = app
          @clients = []
          hook_into_reload
        end

        def call(env)
          if Faye::WebSocket.websocket?(env)
            websocket_response(env)
          else
            app.call(env)
          end
        end

        private

        def hook_into_reload
          middleware = self

          ActiveSupport::Reloader.to_prepare do
            AdequateSerialization::Serializer.descendants.each do |serializer|
              next unless serializer.name
              next unless serializer.instance_variable_defined?(:@serializes)

              serializer.remove_instance_variable(:@serializes)
            end

            middleware.clients.each { |client| client.send(Visualizer.to_svg) }
          end
        end

        def websocket_response(env)
          client = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE })

          client.on :open do |event|
            @clients << client
          end

          client.on :close do |event|
            @clients.delete(client)
            client = nil
          end

          client.rack_response
        end
      end

      class Static
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
            use Socket if defined?(Faye::Websocket)
            use Static
            run -> { [404, { 'Content-Type' => 'text/plain' }, ['Not Found']] }
          end
        end
      end
    end
  end
end
