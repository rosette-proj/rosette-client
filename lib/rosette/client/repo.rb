# encoding: UTF-8

module Rosette
  module Client

    class Repo
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def get_head
        execute_in_repo('git symbolic-ref --short HEAD').strip
      end

      def rev_parse(ref)
        commit_id = execute_in_repo("git rev-parse #{ref}").strip
        commit_id ? commit_id : nil
      end

      private

      def execute_in_repo(cmd)
        Dir.chdir(path) do
          `#{cmd}`
        end
      end
    end

  end
end
