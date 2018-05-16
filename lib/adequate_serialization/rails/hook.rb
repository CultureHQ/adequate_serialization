# frozen_string_literal: true

require 'adequate_serialization/rails/cache_key'
require 'adequate_serialization/rails/cache_step'
require 'adequate_serialization/rails/relation_serializer'

module AdequateSerialization
  module Rails
    module RecordHook
      def self.included(base)
        base.include(Serializable)
        base.alias_method(:as_json, :serialized)
      end
    end

    module RelationHook
      def as_json(*options)
        RelationSerializer.new(self).serialized(*options)
      end
    end

    def self.hook_in!
      ActiveRecord::Base.include(RecordHook)
      ActiveRecord::Relation.include(RelationHook)
      AdequateSerialization.prepend(CacheStep)
    end
  end
end
