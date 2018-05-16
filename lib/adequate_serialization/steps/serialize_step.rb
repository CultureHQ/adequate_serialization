# frozen_string_literal: true

module AdequateSerialization
  module Steps
    class SerializeStep < PassthroughStep
      def apply(response)
        object = response.object
        serialized = object.class.serializer.serialize(object, response.opts)

        apply_next(response.mutate(serialized))
      end
    end
  end
end
