# encoding: UTF-8

require 'spec_helper'

include Rosette::Client
include Rosette::Client::Commands

describe UntranslatedCommand do
  let(:api) { double }
  let(:base_repo) { TmpRepo.new }
  let(:repo) { Repo.new(base_repo.working_dir) }
  let(:terminal) { FakeTerminal.new }
  let(:writer) { FakeWriter.new }
  let(:repo_name) { 'my_awesome_repo' }
  let(:commit_id) { base_repo.git('rev-parse HEAD').strip }
  let(:command) do
    UntranslatedCommand.new(api, terminal, writer, repo, [commit_id])
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
    it "makes an 'untranslated_phrases' api call" do
      expect(api).to receive(:untranslated_phrases)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(Response.from_api_response({}))

      command.execute
    end

    it 'prints out a list of untranslated phrases by locale' do
      expect(api).to receive(:untranslated_phrases)
        .with(repo_name: repo_name, ref: commit_id)
        .and_return(
          Response.from_api_response(
            'ja-JP' => [
              { 'key' => 'Mercury', 'meta_key' => 'planet.first' },
              { 'key' => 'Venus', 'meta_key' => 'planet.second' }
            ],
            'fr-FR' => [
              { 'key' => 'Earth', 'meta_key' => 'planet.third' },
              { 'key' => 'Mars', 'meta_key' => 'planet.fourth' }
            ]
          )
        )

      command.execute

      expect(terminal.all_statements).to eq([
        'Locale: ja-JP', '>> Mercury (planet.first)', '>> Venus (planet.second)', '',
        'Locale: fr-FR', '>> Earth (planet.third)', '>> Mars (planet.fourth)'
      ])
    end
  end
end
