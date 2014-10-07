# encoding: UTF-8

# git rs snapshot <ref>

module Rosette
  module Client
    module Commands

      SnapshotCommandArgs = Struct.new(:ref) do
        def self.from_argv(argv, repo)
          new(argv[0] || repo.get_head)
        end
      end

      # a show is really just a diff against your parent (so the inheritance makes sense)
      class SnapshotCommand < Command
        attr_reader :args

        def initialize(api, terminal, repo, argv)
          super(api, terminal, repo)
          @args = SnapshotCommandArgs.from_argv(argv, repo)
        end

        def execute
          response = api.snapshot(
            repo_name: derive_repo_name,
            ref: args.ref
          )

          handle_error(response) do |diff|
            terminal.say(diff.inspect)
          end
        end
      end

    end
  end
end
