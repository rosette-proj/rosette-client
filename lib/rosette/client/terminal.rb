# encoding: UTF-8

require 'colorize'

module Rosette
  module Client
    class Terminal

      def say(str, color = :none)
        puts colorize(str, color)
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
