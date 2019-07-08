# frozen_string_literal: true

class CacheVisualizationTest < Minitest::Test
  include Rack::Test::Methods

  def test_favicon
    get '/favicon.ico'

    assert last_response.ok?
    assert_equal 'image/vnd.microsoft.icon', last_response.media_type
  end

  def test_index
    fileio =
      with_dot do
        get '/'

        assert last_response.ok?
        assert_equal 'text/html', last_response.media_type
      end

    ['Comment -> Post', 'Tag -> Post', 'Post -> Comment'].each do |edge|
      assert_includes fileio.content, edge
    end
  end

  def test_not_found
    get '/not_found'

    assert last_response.not_found?
  end

  private

  def app
    AdequateSerialization::Rails::CacheVisualization
  end

  class FileIO
    attr_reader :content

    def initialize
      @content = ''
    end

    def write(content)
      @content << content
    end

    alias readlines content
    def close_write; end
  end

  def with_dot(&block)
    FileIO.new.tap do |fileio|
      IO.stub(:popen, [nil, nil, nil, '<svg></svg>'], fileio, &block)
    end
  end
end
