# encoding: UTF-8

module Rosette
  module Client

    class Response
      def self.from_api_response(hash_or_array)
        case hash_or_array
          when Hash
            HashResponse.new(hash_or_array)
          else
            ArrayResponse.new(hash_or_array)
        end
      end
    end

    class HashResponse
      attr_reader :attributes

      def initialize(hash)
        @attributes = hash
      end

      def error?
        attributes.include?('error')
      end

      def success?
        !error?
      end

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

    class ArrayResponse < Array
      def initialize(array)
        replace(array)
      end

      def error?
        false
      end

      def success?
        true
      end

      def attributes
        self
      end
    end

  end
end
