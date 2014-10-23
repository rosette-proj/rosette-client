# encoding: UTF-8

module Rosette
  module Client

    class Response
      attr_reader :attributes

      def self.from_api_response(hash)
        new(hash)
      end

      def initialize(hash)
        @attributes = hash
      end

      def error?
        attributes.include?('error')
      end

      def success?
        !error?
      end

      private

      def method_missing(method, *args, &block)
        if attributes.include?(method.to_s)
          attributes[method.to_s]
        end
      end

      # responds to everything, returns nil for any unset attributes
      def respond_to?(method)
        true
      end
    end

  end
end
