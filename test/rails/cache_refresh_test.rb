# frozen_string_literal: true

require 'test_helper'

class CacheRefreshTest < Minitest::Test
  include ActiveJob::TestHelper

  CacheRefreshJob = AdequateSerialization::CacheRefresh::CacheRefreshJob

  def test_serialized_associations
    assert_equal %i[post], Comment.serialized_associations
  end

  def test_enqueues_refresh
    comment = Comment.first

    assert_enqueued_jobs 1, only: CacheRefreshJob do
      comment.update(body: 'This is a test.')
    end

    arguments = enqueued_jobs[0][:args]
    assert_equal comment, ActiveJob::Arguments.deserialize(arguments)[0]
  end

  def test_enqueues_refresh_after_commit_only
    comment = Comment.first

    assert_no_enqueued_jobs do
      ApplicationRecord.transaction do
        comment.update(body: 'This is a test')
        raise ActiveRecord::Rollback
      end
    end
  end

  def test_updates_one
    comment = Comment.first
    previous = comment.post.cache_key

    CacheRefreshJob.perform_now(comment)

    refute_equal previous, comment.post.reload.cache_key
  end

  def test_updates_many
    tag = Tag.first
    previous = tag.posts.first.cache_key

    CacheRefreshJob.perform_now(tag)

    refute_equal previous, tag.posts.reload.first.cache_key
  end
end
