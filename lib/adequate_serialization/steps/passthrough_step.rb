# frozen_string_literal: true

module AdequateSerialization
  module Steps
    class LastStep
      def apply(response)
        response.current
      end
    end

    class PassthroughStep
      attr_reader :next_step

      def initialize(next_step = LastStep.new)
        @next_step = next_step
      end

      def apply(response)
        apply_next(response)
      end

      private

      def apply_next(response)
        next_step.apply(response)
      end
    end
  end
end
