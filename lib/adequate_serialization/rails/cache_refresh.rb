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
            end
          end

          # The association will return a record if it's a `has_one` and it was
          # previously created.
          refine ActiveRecord::Base do
            def refresh
              touch
            end
          end

          # The association will return a `nil` if it's a `has_one` and it was
          # not yet created.
          refine NilClass do
            def refresh; end
          end
        end
      )

      queue_as AdequateSerialization.active_job_queue
      discard_on ActiveJob::DeserializationError

      def perform(record)
        record.class.associated_caches.each do |association|
          record.public_send(association).refresh
        end
      end
    end

    def self.extended(base)
      base.after_update_commit { CacheRefreshJob.perform_later(self) }
    end

    def associate_cache(association)
      associated_caches << association
    end

    # The associations that serialize this object in their responses, so that we
    # know to bust their cache when this object is updated.
    def associated_caches
      @associated_caches ||= []
    end
  end
end
