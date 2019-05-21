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

    using(
      Module.new do
        refine ActiveRecord::Reflection::AssociationReflection do
          def validate
            # If the association is polymorphic, we can't rely on the inverse
            # to tell us information about cache busting because there are
            # multiple inverse associations.
            return if polymorphic?

            record = active_record.name
            raise InverseNotFoundError.new(record, name) unless inverse_of

            if inverse_of.macro == :belongs_to && !inverse_of.options[:touch]
              raise TouchNotFoundError.new(record, klass.name, inverse_of.name)
            end
          end
        end
      end
    )

    # Used as a shim for the `validate` API in the case that an attribute on the
    # serializer does not represent an association.
    module NullAssociation
      def self.validate; end
    end

    # Overrides the previous `attribute` declaration to add some addition
    # validation in the case that we're serializing an ActiveRecord object.
    def attribute(*names, &block)
      record = serializes

      if record < ActiveRecord::Base
        (names.last.is_a?(Hash) ? names[0..-2] : names).each do |attribute|
          (record.reflect_on_association(attribute) || NullAssociation).validate
        end
      end

      super
    end
  end
end
