# frozen_string_literal: true

module AdequateSerialization
  module Serializable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def serializer
        @serializer ||= const_get("#{name}Serializer").new
      end
    end

    def serialized(*opts)
      Steps.apply(self, *opts)
    end
  end
end
