# encoding: UTF-8

require 'yaml'

module Rosette
  module Client

    class Cli
      attr_reader :api, :terminal, :writer, :repo

      def initialize(terminal, writer, api, repo)
        @api = api
        @terminal = terminal
        @writer = writer
        @repo = repo
      end

      def start(argv)
        if command_const = find_command_const(argv.first)
          command_const.new(api, terminal, writer, repo, argv[1..-1]).execute
        else
          terminal.say("Command '#{argv.first}' not recognized.")
        end
      rescue Rosette::Client::ApiError => e
        terminal.say("An api error occurred: #{e.message}")
      end

      private

      def find_command_const(name)
        const = const_name(name)
        if Rosette::Client::Commands.const_defined?(const)
          Rosette::Client::Commands.const_get(const)
        end
      end

      def const_name(name)
        name.downcase.gsub(/(\A\w|_\w)/) { $1.sub('_', '').upcase } + 'Command'
      end
    end

  end
end
