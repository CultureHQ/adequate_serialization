# frozen_string_literal: true

class RelationSerializerTest < Minitest::Test
  include AdequateSerialization::Rails

  def setup
    Rails.cache.clear
  end

  def test_cacheable
    relation = Post.all

    serialized = RelationSerializer.new(relation).serialized
    assert_equal relation.size, serialized.size
    assert_equal relation.size, entries

    relation.each_with_index do |record, index|
      assert_equal serialized[index], Rails.cache.fetch(record)
    end
  end

  def test_non_cacheable
    relation = Post.select(:id, :title, :created_at)

    serialized = RelationSerializer.new(relation).serialized
    assert_equal relation.size, serialized.size
    assert entries.zero?
  end

  def test_attaches_objects
    relation = Post.all
    attachments =
      relation.each_with_object({}) do |record, attached|
        attached[record.id] = record.title * 2
      end

    options = { attach: { doubled_title: attachments } }
    serialized = RelationSerializer.new(relation).serialized(options)

    assert_equal relation.size, serialized.size
    assert_equal relation.size, entries

    relation.each_with_index do |record, index|
      refute Rails.cache.fetch(record).key?(:doubled_title)
      assert_equal record.title * 2, serialized[index][:doubled_title]
    end
  end

  private

  # Why is there no quick way to determine how many entries are in the cache?
  def entries
    Rails.cache.instance_variable_get(:@data).size
  end
end
