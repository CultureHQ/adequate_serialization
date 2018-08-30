# frozen_string_literal: true

class RelationSerializerTest < Minitest::Test
  include AdequateSerialization::Rails

  module SQLCounter
    class << self
      attr_reader :log

      def clear
        @log = []
      end

      def call(*, values)
        @log << values[:sql]
      end
    end

    clear

    ActiveSupport::Notifications.subscribe('sql.active_record', self)
  end

  def setup
    Rails.cache.clear
  end

  def test_cacheable
    relation = Post.all

    serialized = RelationSerializer.new(relation).as_json
    assert_equal relation.size, serialized.size
    assert_equal relation.size, entries

    relation.each_with_index do |record, index|
      assert_equal serialized[index], Rails.cache.fetch(record)
    end
  end

  def test_non_cacheable
    relation = Post.select(:id, :title, :created_at)

    serialized = RelationSerializer.new(relation).as_json
    assert_equal relation.size, serialized.size
    assert entries.zero?
  end

  def test_attaches_objects
    relation = Post.all
    serialized =
      RelationSerializer.new(relation).as_json(attach_options_for(relation))

    assert_equal relation.size, serialized.size
    assert_equal relation.size, entries
    assert_correct_attachment_behavior relation, serialized
  end

  def test_does_not_trigger_extra_queries_when_not_loaded
    relation = Post.all

    assert_queries 1 do
      RelationSerializer.new(relation).as_json
    end
  end

  def test_does_not_trigger_extra_queries_when_loaded
    relation = Post.all.tap(&:load)

    assert_no_queries do
      RelationSerializer.new(relation).as_json
    end
  end

  private

  def assert_correct_attachment_behavior(relation, serialized)
    relation.each_with_index do |record, index|
      refute Rails.cache.fetch(record).key?(:double_id)
      assert_equal record.id * 2, serialized[index][:double_id]
    end
  end

  def assert_no_queries(&block)
    assert_queries(0, &block)
  end

  def assert_queries(number)
    SQLCounter.clear
    yield.tap { assert_equal number, SQLCounter.log.size }
  end

  # Why is there no quick way to determine how many entries are in the cache?
  def entries
    Rails.cache.instance_variable_get(:@data).size
  end

  def attach_options_for(relation)
    attachments =
      relation.each_with_object({}) do |record, attached|
        attached[record.id] = record.id * 2
      end

    { attach: { double_id: attachments } }
  end
end
