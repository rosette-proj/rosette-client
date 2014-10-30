# encoding: UTF-8

require 'spec_helper'

include Rosette::Client
include Rosette::Client::Commands

describe StatusCommand do
  let(:api) { double }
  let(:base_repo) { TmpRepo.new }
  let(:repo) { Repo.new(base_repo.working_dir) }
  let(:terminal) { FakeTerminal.new }
  let(:repo_name) { 'my_awesome_repo' }
  let(:commit_id) { base_repo.git('rev-parse HEAD').strip }
  let(:command) { StatusCommand.new(api, terminal, repo, [commit_id]) }

  before(:each) do
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
      expect(api).to receive(:status)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(Response.new({}))

      command.execute
    end

    it 'prints the status as a table' do
      expect(api).to receive(:status)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(
          Response.new({
            'commit_id' => commit_id,
            'status' => 'UNTRANSLATED',
            'phrase_count' => 10,
            'locales' => [{
              'locale' => 'fr-FR',
              'percent_translated' => 0.5,
              'translated_count' => 5
            }, {
              'locale' => 'pt-BR',
              'percent_translated' => 0.2,
              'translated_count' => 2
            }]
          })
        )

      command.execute

      expect(terminal).to have_said(Regexp.compile(['fr-FR', '10', '5', '0.5'].join('[ ]*\|[ ]*')))
      expect(terminal).to have_said(Regexp.compile(['pt-BR', '10', '2', '0.2'].join('[ ]*\|[ ]*')))
    end

    it 'prints the error if the api response contains one' do
      expect(api).to receive(:status)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(
          Response.new({ 'error' => 'Jelly beans' })
        )

      command.execute
      expect(terminal).to have_said('Jelly beans')
    end
  end
end
