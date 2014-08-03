# encoding: UTF-8

# git rs commit <ref>

module Rosette
  module Client
    module Commands

      CommitCommandArgs = Struct.new(:ref) do
        def self.from_argv(argv, repo)
          new(argv[0] || repo.get_head)
        end
      end

      class CommitCommand < Command
        attr_reader :args

        def initialize(api, terminal, repo, argv)
          super(api, terminal, repo)
          @args = CommitCommandArgs.from_argv(argv, repo)
        end

        def execute
          terminal.say("Committing phrases for '#{args.ref}'...")

          response = api.commit(
            repo_name: derive_repo_name,
            ref: args.ref
          )

          handle_error(response) do
            terminal.say('done.')
          end
        end
      end

    end
  end
end