# encoding: UTF-8

require 'colorize'

module Rosette
  module Client
    class Terminal

      attr_reader :stream

      def initialize(stream = STDOUT)
        @stream = stream
      end

      def say(str, color = :none)
        stream.write(colorize(str, color))
      end

      private

      def colorize(str, color)
        case color
          when :none
            str
          else
            str.colorize(color)
        end
      end

    end
  end
end
