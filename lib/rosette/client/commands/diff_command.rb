# encoding: UTF-8

# git rs diff <ref1> [<ref2> | <path>] [-- <path1> <path2> ...]

# git rs diff
# git rs diff master .
# git rs diff master branch
# git rs diff master branch .
# git rs diff master branch -- path/to/files

module Rosette
  module Client
    module Commands

      DiffCommandArgs = Struct.new(:diff_point_ref, :head_ref, :paths) do
        # should probably use a parser for these args, since they're pretty complicated
        # currently no support for options like --name-only, etc
        def self.from_argv(argv, repo)
          diff_point_ref = argv[0] || 'refs/heads/master'
          paths = []

          if argv[1]
            if File.exist?(argv[1])
              paths << argv[1]
            else
              head_ref = argv[1] unless argv[1] == '--'
            end
          end

          head_ref ||= repo.get_head

          (2..argv.size).each do |i|
            next if argv[i] == '--'
            if argv[i] && File.exist?(argv[i])
              paths << argv[i]
            end
          end

          new(diff_point_ref, head_ref, paths)
        end
      end

      class DiffCommand < Command
        attr_reader :args

        def initialize(api, terminal, repo, argv)
          super(api, terminal, repo)
          @args = DiffCommandArgs.from_argv(argv, repo)
        end

        def execute
          response = api.diff(
            repo_name: derive_repo_name,
            head_ref: args.head_ref,
            diff_point_ref: args.diff_point_ref,
            paths: args.paths.join(' ')
          )

          handle_error(response) do |diff|
            print_diff(diff)
          end
        end

        private

        def print_diff(diff)
          group_diff_by_file(diff).each_pair do |path, states|
            terminal.say("diff --rosette a/#{path} b/#{path}", :white)

            states.each do |state, changes|
              changes.each do |change|
                str = "#{change['key']}"

                meta_key = change['meta_key']

                unless meta_key.empty?
                  str += "(#{meta_key})"
                end

                case state
                  when 'modified'
                    terminal.say("- #{str}", :red)
                    terminal.say("+ #{str}", :green)
                  when 'removed'
                    terminal.say("- #{str}", :red)
                  when 'added'
                    terminal.say("+ #{str}", :green)
                end
              end
            end
          end
        end
      end

    end
  end
end
