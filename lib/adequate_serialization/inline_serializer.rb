# frozen_string_literal: true

module AdequateSerialization
  # With this module, you can define serializers inline in the object that
  # they're serializing. You use it with the `AdequateSerialization::inline`
  # method to define the serializer dynamically, as in:
  #
  # class User
  #   attr_reader :id, :name, :title
  #
  #   def initialize(id:, name:, title: nil)
  #     @id = id
  #     @name = name
  #     @title = title
  #   end
  #
  #   include AdequateSerialization.inline {
  #     attribute :id, :name
  #     attribute :title, optional: true
  #   }
  # end
  #
  # user = User.new(id: 1, name: 'Clark Kent')
  # user.as_json
  # # => {:id=>1, :name=>"Clark Kent"}
  #
  # user = User.new(id: 2, name: 'Diana Prince', title: 'Wonder Woman')
  # user.as_json(includes: :title)
  # # => {:id=>1, :name=>"Diana Prince", :title=>"Wonder Woman"}
  class InlineSerializer < Module
    attr_reader :block

    def initialize(&block)
      @block = block
    end

    def included(base)
      base.include(Serializable)

      serializer_class = Class.new(Serializer)

      # In order to validate the attribute, we need to define the `serializes`
      # method before we evaluate the block
      serializer_class.define_singleton_method(:serializes) { base }
      serializer_class.class_eval(&block)

      # No need to memoize within the method because the block will hold on to
      # local variables for us.
      serializer = serializer_class.new
      base.define_singleton_method(:serializer) { serializer }
    end
  end

  def self.inline(&block)
    InlineSerializer.new(&block)
  end
end
