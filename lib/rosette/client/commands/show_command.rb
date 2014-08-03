# encoding: UTF-8

# git rs show <ref>

module Rosette
  module Client
    module Commands

      ShowCommandArgs = Struct.new(:ref) do
        def self.from_argv(argv, repo)
          new(argv[0] || repo.get_head)
        end
      end

      # a show is really just a diff against your parent (so the inheritance makes sense)
      class ShowCommand < DiffCommand
        attr_reader :args

        def initialize(api, terminal, repo, argv)
          @api = api
          @terminal = terminal
          @repo = repo
          @args = ShowCommandArgs.from_argv(argv, repo)
        end

        def execute
          response = api.show(
            repo_name: derive_repo_name,
            ref: args.ref
          )

          handle_error(response) do |diff|
            print_diff(diff)
          end
        end
      end

    end
  end
end
