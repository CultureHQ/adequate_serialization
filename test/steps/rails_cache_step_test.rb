# frozen_string_literal: true

require 'test_helper'

class RailsCacheStepTest < Minitest::Test
  include AdequateSerialization::Steps

  def test_a_non_record_non_cachable_object
    object = Object.new
    options = AdequateSerialization::Options.null

    response = Response.new(object, options, 'foo')
    current = RailsCacheStep.new.apply(response)

    assert_equal 'foo', current

    assert_nil Rails.cache.fetch(object)
  end

  def test_a_non_record_cachable_object
    user = User.new.tap { |entry| Rails.cache.delete(entry) }
    options = AdequateSerialization::Options.null

    response = Response.new(user, options, 'foo')
    current = RailsCacheStep.new.apply(response)

    assert_equal 'foo', current
    assert_equal 'foo', Rails.cache.fetch(user)
  end

  def test_a_record_that_is_cacheable
    post = Post.first.tap { |entry| Rails.cache.delete(entry) }
    options = AdequateSerialization::Options.null

    response = Response.new(post, options, 'foo')
    current = RailsCacheStep.new.apply(response)

    assert_equal 'foo', current
    assert_equal 'foo', Rails.cache.fetch(post)
  end

  def test_a_record_that_is_cacheable_with_includes
    post = Post.first.tap { |entry| Rails.cache.delete(entry) }
    options = AdequateSerialization::Options.from(includes: :comments)

    response = Response.new(post, options, 'foo')
    current = RailsCacheStep.new.apply(response)

    assert_equal 'foo', current
    assert_equal 'foo', Rails.cache.fetch([post, :comments])
  end

  def test_a_record_that_is_not_cachable
    post = Post.select(:id).first
    options = AdequateSerialization::Options.null

    response = Response.new(post, options, 'foo')
    current = RailsCacheStep.new.apply(response)

    assert_equal 'foo', current
  end

  def test_when_multi_caching_was_passed
    post = Post.first.tap { |entry| Rails.cache.delete(entry) }
    options = AdequateSerialization::Options.from(multi_caching: true)

    response = Response.new(post, options, 'foo')
    current = RailsCacheStep.new.apply(response)

    assert_equal 'foo', current
    assert_nil Rails.cache.fetch(post)
  end
end
