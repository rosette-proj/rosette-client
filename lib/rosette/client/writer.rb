# encoding: UTF-8

require 'yaml'

module Rosette
  module Client

    class Writer
      def self.open(path, mode, &block)
        File.open(path, mode, &block)
      end
    end

  end
end
