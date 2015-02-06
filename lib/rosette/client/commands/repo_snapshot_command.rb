# encoding: UTF-8

# git rs snapshot <ref>

module Rosette
  module Client
    module Commands

      RepoSnapshotCommandArgs = Struct.new(:ref) do
        def self.from_argv(argv, repo)
          new(repo.rev_parse(argv[0] || repo.get_head))
        end
      end

      # a show is really just a diff against your parent (so the inheritance makes sense)
      class RepoSnapshotCommand < Command
        def execute
          response = api.repo_snapshot(
            repo_name: derive_repo_name,
            ref: args.ref
          )

          handle_error(response) do |response|
            print_hash(response.attributes)
          end
        end

        private

        def parse_args(args)
          RepoSnapshotCommandArgs.from_argv(args, repo)
        end
      end

    end
  end
end
