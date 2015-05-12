# encoding: UTF-8

# git rs pull [ref] -f file_pattern -s serializer

require 'base64'
require 'optparse'

module Rosette
  module Client
    module Commands

      PullCommandArgs = Struct.new(:ref, :file_pattern, :serializer, :paths) do
        def self.from_argv(argv, repo, terminal)
          options = { paths: '' }

          parser = OptionParser.new do |opts|
            desc = "File pattern to use. Can contain these placeholders:\n" +
              "* %{locale.code}: The full locale code, eg. pt-BR\n" +
              "* %{locale.territory}: The locale's territory part, eg. 'BR'" +
              "* %{locale.language}: The locale's language part, eg. 'pt'"

            opts.on('-f pattern', '--file-pattern pattern', desc) do |pattern|
              pattern.strip!
              options[:file_pattern] = pattern.empty? ? nil : pattern
            end

            desc = 'The serializer to use. Translations will be requested in ' +
              'this format.'

            opts.on('-s serializer', '--serializer serializer', desc) do |serializer|
              serializer.strip!
              options[:serializer] = serializer.empty? ? nil : serializer
            end

            desc = 'The paths to use to restrict the export to only phrases ' +
              'found at those paths. Should be pipe-separated.'

            opts.on('-p paths', '--paths paths', desc) do |path|
              options[:paths] = path.strip
            end
          end

          parser.parse(argv)
          options[:ref] = repo.rev_parse(argv[0] || repo.get_head)
          validate_options!(options, terminal)

          new(
            options[:ref],
            options[:file_pattern],
            options[:serializer],
            options[:paths]
          )
        end

        def self.validate_options!(options, terminal)
          unless options.include?(:file_pattern)
            terminal.say('Please supply a file pattern via the -f option')
            exit 1
          end

          unless options.include?(:serializer)
            terminal.say('Please supply a serializer via the -s option')
            exit 1
          end
        end
      end

      # a show is really just a diff against your parent (so the inheritance makes sense)
      class PullCommand < Command
        def execute
          locales = api.locales(
            repo_name: derive_repo_name
          )

          handle_error(locales) do |locales|
            export_locales(locales)
          end
        end

        private

        def parse_args(args)
          PullCommandArgs.from_argv(args, repo, terminal)
        end

        def export_locales(locales)
          locales.each do |locale|
            export_locale(locale)
          end
        end

        def export_locale(locale)
          response = api.export({
            repo_name: derive_repo_name,
            ref: args.ref,
            locale: locale['code'],
            serializer: args.serializer,
            base_64_encode: true,
            paths: args.paths
          })

          handle_error(response) do |response|
            payload = Base64.decode64(response.payload)
            path = path_for(locale)
            terminal.say("Writing #{path}")

            writer.open(path, 'w+') do |f|
              f.write(payload)
            end
          end
        end

        def path_for(locale)
          args.file_pattern % {
            :'locale.code' => locale['code'],
            :'locale.territory' => locale['territory'],
            :'locale.language' => locale['language']
          }
        end
      end

    end
  end
end
