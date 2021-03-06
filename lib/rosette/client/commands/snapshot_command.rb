# encoding: UTF-8

# git rs snapshot <ref>

module Rosette
  module Client
    module Commands

      SnapshotCommandArgs = Struct.new(:ref) do
        def self.from_argv(argv, repo)
          new(repo.rev_parse(argv[0] || repo.get_head))
        end
      end

      # a show is really just a diff against your parent (so the inheritance makes sense)
      class SnapshotCommand < Command
        def execute
          response = api.snapshot(
            repo_name: derive_repo_name,
            ref: args.ref
          )

          handle_error(response) do |response|
            response.attributes.each do |item|
              print_hash(item)
              terminal.say('')
            end
          end
        end

        def parse_args(args)
          SnapshotCommandArgs.from_argv(args, repo)
        end
      end

    end
  end
end
