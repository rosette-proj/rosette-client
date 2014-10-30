# encoding: UTF-8

require 'spec_helper'

include Rosette::Client
include Rosette::Client::Commands

describe ShowCommand do
  let(:api) { double }
  let(:base_repo) { TmpRepo.new }
  let(:repo) { Repo.new(base_repo.working_dir) }
  let(:terminal) { FakeTerminal.new }
  let(:repo_name) { 'my_awesome_repo' }
  let(:commit_id) { base_repo.git('rev-parse HEAD').strip }
  let(:command) { ShowCommand.new(api, terminal, repo, [commit_id]) }

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
      expect(api).to receive(:show)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(Response.new({}))

      command.execute
    end

    it 'prints the phrases that were added, removed, and modified' do
      expect(api).to receive(:show)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(
          Response.new(sample_diff(commit_id))
        )

      command.execute

      expect(terminal).to have_said("+ I'm a little teapot (about.training.teapot)", :green)
      expect(terminal).to have_said('- The green albatross flitters in the moonlight (animals.birds.albatross.message)', :red)

      expect(terminal).to have_said('+ Purple eggplants make delicious afternoon snacks (foods.vegetables.eggplant.snack_message)', :green)
      expect(terminal).to have_said('- Blue eggplants make wonderful evening meals (foods.vegetables.eggplant.snack_message)', :red)

      expect(terminal).to have_said('+ The Seattle Seahawks rock (sports.teams.football.best)', :green)
      expect(terminal).to have_said('- The Seattle Seahawks rule (sports.teams.football.best)', :red)
    end

    it 'prints the error if the api response contains one' do
      expect(api).to receive(:show)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(
          Response.new({ 'error' => 'Jelly beans' }.merge(sample_diff(commit_id)))
        )

      command.execute

      expect(terminal).to have_said('Jelly beans')
      expect(terminal).to_not have_said("+ I'm a little teapot (about.training.teapot)", :green)
    end
  end
end
