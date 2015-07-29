# encoding: UTF-8

# git rs untranslated [ref]

module Rosette
  module Client
    module Commands

      UntranslatedCommandArgs = Struct.new(:ref) do
        def self.from_argv(argv, repo)
          new(repo.rev_parse(argv[0] || repo.get_head))
        end
      end

      class UntranslatedCommand < Command
        def execute
          response = api.untranslated_phrases(
            repo_name: derive_repo_name,
            ref: args.ref
          )

          handle_error(response) do |response|
            response.attributes.each_pair.with_index do |(locale, phrases), idx|
              terminal.say('') if idx > 0
              terminal.say("Locale: #{locale}", color: :white)

              phrases.each do |phrase|
                terminal.say(
                  ">> #{phrase['key']} (#{phrase['meta_key']})", color: :red
                )
              end
            end
          end
        end

        private

        def parse_args(args)
          UntranslatedCommandArgs.from_argv(args, repo)
        end
      end

    end
  end
end
