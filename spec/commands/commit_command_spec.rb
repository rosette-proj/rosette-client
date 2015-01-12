# encoding: UTF-8

require 'spec_helper'

include Rosette::Client
include Rosette::Client::Commands

describe CommitCommand do
  let(:api) { double }
  let(:base_repo) { TmpRepo.new }
  let(:repo) { Repo.new(base_repo.working_dir) }
  let(:terminal) { FakeTerminal.new }
  let(:repo_name) { 'my_awesome_repo' }
  let(:commit_id) { base_repo.git('rev-parse HEAD').strip }
  let(:command) { CommitCommand.new(api, terminal, repo, [commit_id]) }

  before(:each) do
    add_user_to(base_repo)
    base_repo.git("remote add origin git@github.com/camertron/#{repo_name}")
    base_repo.create_file('file.txt') { |f| f.write('hello, world') }
    base_repo.add_all
    base_repo.commit('Initial commit')
  end

  around(:each) do |example|
    Dir.chdir(base_repo.working_dir) do
      example.run
    end
  end

  describe '#execute' do
    it 'makes a commit api call' do
      expect(api).to receive(:commit)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(Response.new({}))

      command.execute
    end

    it 'prints the number of phrases added, removed, and modified' do
      expect(api).to receive(:commit)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(
          Response.new(
            { 'added' => 1, 'removed' => 2, 'modified' => 3 }
          )
        )

      command.execute

      expect(terminal).to have_said('Added: 1')
      expect(terminal).to have_said('Removed: 2')
      expect(terminal).to have_said('Modified: 3')
    end

    it 'prints the error if the api response contains one' do
      expect(api).to receive(:commit)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(
          Response.new({ 'error' => 'Jelly beans', 'added' => 1 })
        )

      command.execute

      expect(terminal).to have_said('Jelly beans')
      expect(terminal).to_not have_said('Added: 1')
    end
  end
end
