# encoding: UTF-8

# git rs show <ref>

module Rosette
  module Client
    module Commands

      ShowCommandArgs = Struct.new(:ref) do
        def self.from_argv(argv, repo)
          new(repo.rev_parse(argv[0] || repo.get_head))
        end
      end

      # a show is really just a diff against your parent (so the inheritance makes sense)
      class ShowCommand < DiffCommand
        def execute
          response = api.show(
            repo_name: derive_repo_name,
            ref: args.ref
          )

          handle_error(response) do |response|
            print_diff(response.attributes)
          end
        end

        private

        def parse_args(args)
          ShowCommandArgs.from_argv(args, repo)
        end
      end

    end
  end
end
