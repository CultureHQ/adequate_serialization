# frozen_string_literal: true

module AdequateSerialization
  module CacheRefresh
    class CacheRefreshJob < ActiveJob::Base
      using(
        Module.new do
          # The association will return a relation if it's a `has_many` or a
          # `has_many_through` regardless of how many associated records exist.
          refine ActiveRecord::Relation do
            def refresh
              return unless any?

              update_all(updated_at: Time.now)
              find_each(&:as_json)
            end
          end

          # The association will return a record if it's a `has_one` and it was
          # previously created.
          refine ActiveRecord::Base do
            def refresh
              touch
              as_json
            end
          end

          # The association will return a `nil` if it's a `has_one` and it was
          # not yet created.
          refine NilClass do
            def refresh; end
          end
        end
      )

      queue_as :default
      discard_on ActiveJob::DeserializationError

      def perform(record)
        record.class.serialized_associations.each do |association|
          record.public_send(association).refresh
        end
      end
    end

    def self.extended(base)
      base.after_update_commit { CacheRefreshJob.perform_later(self) }
    end

    def serialize_association(association)
      serialized_associations << association
    end

    def serialized_associations
      @serialized_associations ||= []
    end
  end
end
