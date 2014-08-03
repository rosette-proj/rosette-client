# encoding: UTF-8

require 'yaml'

module Rosette
  module Client

    class Cli
      attr_reader :api, :terminal, :repo

      def initialize(terminal, repo)
        @api = get_api
        @terminal = terminal
        @repo = repo
      end

      def start(argv)
        if command_const = find_command_const(argv.first)
          command_const.new(api, terminal, repo, argv[1..-1]).execute
        else
          terminal.say("Command '#{argv.first}' not recognized.")
        end
      rescue ApiError => e
        terminal.say("An api error occurred: #{e.message}")
      end

      private

      def get_api
        config = if File.exist?(config_file)
          YAML.load_file(config_file)
        else
          {}
        end

        Api.new(config)
      end

      def config_file
        @config_file ||= File.join(Dir.home, '.rosette/config.yml')
      end

      def find_command_const(name)
        const = const_name(name)
        if Rosette::Client::Commands.const_defined?(const)
          Rosette::Client::Commands.const_get(const)
        end
      end

      def const_name(name)
        name.downcase.sub(/\A(\w)/) { $1.upcase } + 'Command'
      end
    end

  end
end
