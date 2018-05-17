# frozen_string_literal: true

require 'adequate_serialization/attribute'
require 'adequate_serialization/decorator'
require 'adequate_serialization/options'
require 'adequate_serialization/serializable'
require 'adequate_serialization/serializer'
require 'adequate_serialization/steps'
require 'adequate_serialization/version'

require 'adequate_serialization/steps/passthrough_step'
require 'adequate_serialization/steps/serialize_step'

module AdequateSerialization
  class << self
    def dump(object)
      if object.is_a?(Hash)
        object
      elsif object.respond_to?(:as_json)
        object.as_json
      else
        object
      end
    end

    def hook_into_rails!
      @hook_into_rails ||=
        begin
          require 'adequate_serialization/rails/hook'
          Rails.hook_in!
        end
    end
  end
end
