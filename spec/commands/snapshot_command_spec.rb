# encoding: UTF-8

require 'spec_helper'

include Rosette::Client
include Rosette::Client::Commands

describe SnapshotCommand do
  let(:api) { double }
  let(:base_repo) { TmpRepo.new }
  let(:repo) { Repo.new(base_repo.working_dir) }
  let(:terminal) { FakeTerminal.new }
  let(:repo_name) { 'my_awesome_repo' }
  let(:commit_id) { base_repo.git('rev-parse HEAD').strip }
  let(:command) { SnapshotCommand.new(api, terminal, repo, [commit_id]) }

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
    it 'makes a snapshot api call' do
      expect(api).to receive(:snapshot)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(Response.new({}))

      command.execute
    end

    it 'prints the array of phrases' do
      expect(api).to receive(:snapshot)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(
          Response.new([
            { 'key' => 'Foo', 'commit_id' => 'abc123' },
            { 'key' => 'Bar', 'commit_id' => 'def456' },
            { 'key' => 'Baz', 'commit_id' => 'ghi789' }
          ])
        )

      command.execute

      expect(terminal).to have_said('key: Foo')
      expect(terminal).to have_said('commit_id: abc123')
      expect(terminal).to have_said('key: Bar')
      expect(terminal).to have_said('commit_id: def456')
      expect(terminal).to have_said('key: Baz')
      expect(terminal).to have_said('commit_id: ghi789')
    end

    it 'prints the error if the api response contains one' do
      expect(api).to receive(:snapshot)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(
          Response.new({ 'error' => 'Jelly beans' })
        )

      command.execute
      expect(terminal).to have_said('Jelly beans')
    end
  end
end
