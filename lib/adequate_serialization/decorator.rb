# frozen_string_literal: true

module AdequateSerialization
  module Decorator
    class Null
      def decorate(result)
        result
      end
    end

    class Attachments
      attr_reader :attachments

      def initialize(attachments)
        @attachments = attachments
      end

      def decorate(result)
        attachments.each do |name, attachment|
          result[name] = attachment[result[:id]]
        end

        result
      end
    end

    def self.from(attachments)
      attachments.empty? ? Null.new : Attachments.new(attachments)
    end
  end
end
