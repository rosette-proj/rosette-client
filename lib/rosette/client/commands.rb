# encoding: UTF-8

module Rosette
  module Client
    module Commands

      autoload :DiffCommand,     'rosette/client/commands/diff_command'
      autoload :ShowCommand,     'rosette/client/commands/show_command'
      autoload :CommitCommand,   'rosette/client/commands/commit_command'
      autoload :SnapshotCommand, 'rosette/client/commands/snapshot_command'

      class Command
        attr_reader :api, :terminal, :repo

        def initialize(api, terminal, repo)
          @api = api
          @terminal = terminal
          @repo = repo
        end

        protected

        def handle_error(response)
          if response.include?('error')
            puts response['error']
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
