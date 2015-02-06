# encoding: UTF-8

# git rs status [ref]

module Rosette
  module Client
    module Commands

      StatusCommandArgs = Struct.new(:ref) do
        def self.from_argv(argv, repo)
          new(repo.rev_parse(argv[0] || repo.get_head))
        end
      end

      # a show is really just a diff against your parent (so the inheritance makes sense)
      class StatusCommand < Command
        def execute
          response = api.status(
            repo_name: derive_repo_name,
            ref: args.ref
          )

          handle_error(response) do |response|
            if response.locales && response.phrase_count
              terminal.say(
                build_locale_table(response.locales, response.phrase_count)
              )
            end
          end
        end

        private

        def parse_args(args)
          StatusCommandArgs.from_argv(args, repo)
        end

        HEADER = ['Locale', 'Phrases', 'Translations', 'Percent']

        def build_locale_table(locales, phrase_count)
          rows = build_locale_rows(locales, phrase_count)
          column_widths = find_column_widths(rows)
          rows = pad_rows(rows, column_widths)
          add_markup(rows)
        end

        def add_markup(rows)
          rows = rows.map do |row|
            "| #{row.join(' | ')} |"
          end

          separator = '-' * rows.first.length
          result = rows.join("\n#{separator}\n")
          "#{separator}\n#{result}\n#{separator}"
        end

        def pad_rows(rows, column_widths)
          rows.map do |row|
            row.map.with_index do |col, index|
              col.ljust(column_widths[index], ' ')
            end
          end
        end

        def find_column_widths(rows)
          rows.each_with_object([]) do |row, ret|
            row.each_with_index do |col, index|
              ret[index] ||= []
              ret[index] << col.length
            end
          end.map(&:max)
        end

        def build_locale_rows(locales, phrase_count)
          [HEADER] + locales.map do |locale|
            build_locale_table_row(locale, phrase_count)
          end
        end

        def build_locale_table_row(locale, phrase_count)
          [
            locale['locale'], phrase_count.to_i.to_s,
            locale['translated_count'].to_i.to_s,
            locale['percent_translated'].to_f.to_s
          ]
        end
      end

    end
  end
end
