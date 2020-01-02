# frozen_string_literal: true

require 'test_helper'

class CacheRefreshTest < Minitest::Test
  include ActiveJob::TestHelper

  CacheRefreshJob = AdequateSerialization::CacheRefresh::CacheRefreshJob

  def test_associated_caches
    assert_equal %i[comments post_config tags], Post.associated_caches.sort
  end

  def test_enqueues_refresh
    post = Post.first

    assert_enqueued_jobs 1, only: CacheRefreshJob do
      post.update!(title: 'This is a test.')
    end

    arguments = enqueued_jobs[0][:args]
    assert_equal post, ActiveJob::Arguments.deserialize(arguments)[0]
  end

  def test_enqueues_refresh_after_commit_only
    post = Post.first

    assert_no_enqueued_jobs do
      ApplicationRecord.transaction do
        post.update!(title: 'This is a test')
        raise ActiveRecord::Rollback
      end
    end
  end

  def test_updates_one
    post = Post.first
    previous = post.post_config.cache_key

    CacheRefreshJob.perform_now(post)

    refute_equal previous, post.post_config.reload.cache_key
  end

  def test_updates_many
    post = Post.first
    previous = post.tags.first.cache_key

    CacheRefreshJob.perform_now(post)

    refute_equal previous, post.tags.reload.first.cache_key
  end
end
