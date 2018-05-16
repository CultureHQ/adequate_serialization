# frozen_string_literal: true

require 'test_helper'

class CacheStepTest < Minitest::Test
  AdequateSerialization.hook_into_rails!
  include AdequateSerialization::Rails

  def setup
    Rails.cache.clear
  end

  def test_a_non_record_non_cachable_object
    object = Object.new

    assert_equal object, response_for(object)
    assert_nil Rails.cache.fetch(object)
  end

  def test_a_non_record_cachable_object
    user = User.new

    assert_equal user, response_for(user)
    assert_equal user, Rails.cache.fetch(user)
  end

  def test_a_record_that_is_cacheable
    post = Post.first

    assert_equal post, response_for(post)
    assert_equal post, Rails.cache.fetch(post)
  end

  def test_a_record_that_is_cacheable_with_includes
    post = Post.first

    assert_equal post, response_for(post, includes: :comments)
    assert_equal post, Rails.cache.fetch([post, :comments])
  end

  def test_a_record_that_is_not_cachable
    post = Post.select(:id).first

    assert_equal post, response_for(post)
  end

  def test_when_multi_caching_was_passed
    post = Post.first

    assert_equal post, response_for(post, multi_caching: true)
    assert_nil ::Rails.cache.fetch(post)
  end

  private

  def response_for(object, opts = {})
    options = AdequateSerialization::Options.from(opts)
    response = AdequateSerialization::Steps::Response.new(object, options)

    CacheStep.new.apply(response)
  end
end
