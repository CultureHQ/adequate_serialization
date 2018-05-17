# frozen_string_literal: true

require 'adequate_serialization/rails/cache_key'
require 'adequate_serialization/rails/cache_step'
require 'adequate_serialization/rails/relation_serializer'

module AdequateSerialization
  module Rails
    module RelationHook
      def as_json(*options)
        RelationSerializer.new(self).as_json(*options)
      end
    end

    def self.hook_in!
      ActiveRecord::Base.include(Serializable)
      ActiveRecord::Relation.include(RelationHook)
      AdequateSerialization.prepend(CacheStep)
    end
  end
end
