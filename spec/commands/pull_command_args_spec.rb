# encoding: UTF-8

require 'spec_helper'

include Rosette::Client
include Rosette::Client::Commands

describe PullCommandArgs do
  let(:base_repo) { TmpRepo.new }
  let(:repo) { Repo.new(base_repo.working_dir) }
  let(:terminal) { FakeTerminal.new }
  let(:commit_id) { base_repo.git('rev-parse HEAD').strip }
  let(:repo_name) { 'my_awesome_repo' }

  before(:each) do
    add_user_to(base_repo)
    base_repo.git("remote add origin git@github.com/camertron/#{repo_name}")
    base_repo.create_file('file.txt') { |f| f.write('hello, world') }
    base_repo.add_all
    base_repo.commit('Initial commit')
  end

  describe 'from_argv' do
    it 'exits and prints message when not given a file pattern' do
      expect do
        PullCommandArgs.from_argv(
          [commit_id, '--serializer', 'foo/bar'], repo, terminal
        )
      end.to raise_error(SystemExit)

      expect(terminal).to have_said(
        'Please supply a file pattern via the -f option'
      )
    end

    it 'exits and prints message when not given a serializer' do
      expect do
        PullCommandArgs.from_argv(
          [commit_id, '--file-pattern', 'teapot'], repo, terminal
        )
      end.to raise_error(SystemExit)

      expect(terminal).to have_said(
        'Please supply a serializer via the -s option'
      )
    end
  end
end
