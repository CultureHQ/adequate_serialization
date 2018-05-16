# frozen_string_literal: true

require 'test_helper'

class CacheKeyTest < Minitest::Test
  include AdequateSerialization::Rails

  def test_a_non_record_non_cachable_object
    object = Object.new

    refute CacheKey.cacheable?(object)
  end

  def test_a_non_record_cachable_object
    user = User.new

    assert CacheKey.cacheable?(user)
    assert_equal user, CacheKey.for(user)
  end

  def test_a_record_that_is_cacheable
    post = Post.first

    assert CacheKey.cacheable?(post)
    assert_equal post, CacheKey.for(post)
  end

  def test_a_record_that_is_cacheable_with_includes
    post = Post.first

    assert CacheKey.cacheable?(post)
    assert_equal [post, :comments], CacheKey.for(post, %i[comments])
  end

  def test_a_record_that_is_not_cachable
    post = Post.select(:id).first

    refute CacheKey.cacheable?(post)
  end
end
