# encoding: UTF-8

require 'spec_helper'

include Rosette::Client
include Rosette::Client::Commands

describe RepoSnapshotCommand do
  let(:api) { double }
  let(:base_repo) { TmpRepo.new }
  let(:repo) { Repo.new(base_repo.working_dir) }
  let(:terminal) { FakeTerminal.new }
  let(:writer) { FakeWriter.new }
  let(:repo_name) { 'my_awesome_repo' }
  let(:commit_id) { base_repo.git('rev-parse HEAD').strip }
  let(:command) do
    RepoSnapshotCommand.new(
      api, terminal, writer, repo, [commit_id]
    )
  end

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
    it 'makes a repo_snapshot api call' do
      expect(api).to receive(:repo_snapshot)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(Response.from_api_response({}))

      command.execute
    end

    it 'prints the hash of files to commit ids' do
      expect(api).to receive(:repo_snapshot)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(
          Response.from_api_response({
            'file1.txt' => 'abc123',
            'path/file2.txt' => 'def456',
            'my/awesome/file3.rb' => 'ghi789'
          })
        )

      command.execute

      expect(terminal).to have_said('file1.txt: abc123')
      expect(terminal).to have_said('path/file2.txt: def456')
      expect(terminal).to have_said('my/awesome/file3.rb: ghi789')
    end

    it 'prints the error if the api response contains one' do
      expect(api).to receive(:repo_snapshot)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(
          Response.from_api_response({ 'error' => 'Jelly beans', 'file1.txt' => 'abc123' })
        )

      command.execute

      expect(terminal).to have_said('Jelly beans')
      expect(terminal).to_not have_said('file1.txt: abc123')
    end
  end
end
