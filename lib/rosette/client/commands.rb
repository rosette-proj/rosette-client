# encoding: UTF-8

module Rosette
  module Client
    module Commands

      autoload :CommitCommand,           'rosette/client/commands/commit_command'
      autoload :CommitCommandArgs,       'rosette/client/commands/commit_command'
      autoload :DiffCommand,             'rosette/client/commands/diff_command'
      autoload :DiffCommandArgs,         'rosette/client/commands/diff_command'
      autoload :PullCommand,             'rosette/client/commands/pull_command'
      autoload :PullCommandArgs,         'rosette/client/commands/pull_command'
      autoload :RepoSnapshotCommand,     'rosette/client/commands/repo_snapshot_command'
      autoload :RepoSnapshotCommandArgs, 'rosette/client/commands/repo_snapshot_command'
      autoload :ShowCommand,             'rosette/client/commands/show_command'
      autoload :ShowCommandArgs,         'rosette/client/commands/show_command'
      autoload :SnapshotCommand,         'rosette/client/commands/snapshot_command'
      autoload :SnapshotCommandArgs,     'rosette/client/commands/snapshot_command'
      autoload :StatusCommand,           'rosette/client/commands/status_command'
      autoload :StatusCommandArgs,       'rosette/client/commands/status_command'
      autoload :UntranslatedCommand,     'rosette/client/commands/untranslated_command'
      autoload :UntranslatedCommandArgs, 'rosette/client/commands/untranslated_command'

      class Command
        attr_reader :api, :terminal, :writer, :repo, :args

        def initialize(api, terminal, writer, repo, argv)
          @api = api
          @terminal = terminal
          @writer = writer
          @repo = repo
          @args = parse_args(argv)
        end

        protected

        def parse_args(args)
          raise NotImplementedError,
            "#{__method__} must be defined in derived classes"
        end

        def print_hash(hash)
          hash.each_pair do |key, value|
            terminal.say("#{key}: #{value}")
          end
        end

        def handle_error(response)
          if response.error?
            terminal.say(
              [response.error, response.detail].compact.join(': ')
            )
          else
            yield response if block_given?
          end
        end

        def group_diff_by_file(diff)
          result = Hash.new do |h, i|
            h[i] = Hash.new do |h2, i2|
              h2[i2] = []
            end
          end

          diff.each_with_object(result) do |(state, items), by_path|
            items.each do |item|
              by_path[item['file']][state] << item
            end
          end
        end

        def derive_repo_name
          File.basename(`git config --get remote.origin.url`.strip).gsub(/\.git\z/, '')
        end
      end

    end
  end
end
