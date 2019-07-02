# frozen_string_literal: true

module AdequateSerialization
  module CacheBusting
    class InverseNotFoundError < StandardError
      def initialize(record, association)
        super(<<~MSG)
          In order to be able to bust the associated cache for #{record}'s
          `#{association}` association, that association must have an inverse.
          Currently it doesn't, which means Rails was unable to determine the
          name of the inverse association. You can fix this by adding the
          inverse_of option to the association declaration.
        MSG
      end
    end

    class TouchNotFoundError < StandardError
      def initialize(record, associated, inverse)
        super(<<~MSG)
          #{record} serializes all of the associated #{associated} records,
          which means when #{associated} updates it needs to notify #{record} in
          order to bust the cache. This can be accomplished by adding the
          `touch: true` option to #{associated}'s #{inverse} association.
        MSG
      end
    end

    class ActiveJobNotFoundError < Error
      def initialize(record, association)
        super(<<~MSG)
          In order to be able to bust the associated cache for #{record}'s
          `#{association}` association, AdequateSerialization enqueues a
          background job (since there are potentially multiple records on the
          association). In order to use the background job, it must have access
          to ActiveJob.
        MSG
      end
    end

    using(
      Module.new do
        refine ActiveRecord::Reflection::AssociationReflection do
          def setup
            # If the association is polymorphic, we can't rely on the inverse
            # to tell us information about cache busting because there are
            # multiple inverse associations.
            return if polymorphic?

            unless inverse_of
              raise InverseNotFoundError.new(active_record.name, name)
            end

            inverse_of.macro == :belongs_to ? setup_belongs_to : setup_has_some
          end

          private

          # Ensures that the `belongs_to` association has the `touch` option
          # enabled in order to bust the parent's cache
          def setup_belongs_to
            return if inverse_of.options[:touch]

            record = active_record.name
            raise TouchNotFoundError.new(record, klass.name, inverse_of.name)
          end

          # Hooks into the serialized class and adds cache busting behavior on
          # commit that will loop through the associated records
          def setup_has_some
            unless defined?(ActiveJob)
              raise ActiveJobNotFoundError.new(active_record.name, name)
            end

            require 'adequate_serialization/rails/cache_refresh'

            unless active_record.respond_to?(:serialize_association)
              active_record.extend(CacheRefresh)
            end

            active_record.serialize_association(name)
          end
        end
      end
    )

    # Used as a shim for the `setup` API in the case that an attribute on the
    # serializer does not represent an association.
    module NullAssociation
      def self.setup; end
    end

    # Overrides the previous `attribute` declaration to add some addition
    # validation in the case that we're serializing an ActiveRecord object.
    def attribute(*names, &block)
      record = serializes

      if record < ActiveRecord::Base
        (names.last.is_a?(Hash) ? names[0..-2] : names).each do |attribute|
          (record.reflect_on_association(attribute) || NullAssociation).setup
        end
      end

      super
    end
  end
end
