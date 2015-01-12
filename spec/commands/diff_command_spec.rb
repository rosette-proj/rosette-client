# encoding: UTF-8

require 'spec_helper'

include Rosette::Client
include Rosette::Client::Commands

describe 'diff' do
  let(:args) { DiffCommandArgs }
  let(:base_repo) { TmpRepo.new }
  let(:repo) { Repo.new(base_repo.working_dir) }
  let(:repo_name) { 'my_awesome_repo' }
  let(:new_branch) { 'new_branch' }
  let(:new_branch_commit_id) { base_repo.git("rev-parse #{new_branch}").strip }
  let(:master_commit_id) { base_repo.git("rev-parse master").strip }

  before(:each) do
    add_user_to(base_repo)
    base_repo.git("remote add origin git@github.com/camertron/#{repo_name}")
    base_repo.create_file('file.txt') { |f| f.write('hello, world') }
    base_repo.add_all
    base_repo.commit('Initial commit')
    base_repo.create_branch(new_branch)
    base_repo.create_file('file2.txt') { |f| f.write('another file') }
    base_repo.add_all
    base_repo.commit('Second file')
  end

  around(:each) do |example|
    Dir.chdir(base_repo.working_dir) do
      example.run
    end
  end

  describe DiffCommandArgs do
    it "uses the default head if one isn't provided" do
      args.from_argv(['master'], repo).tap do |args|
        expect(args.diff_point_ref).to eq(master_commit_id)
        expect(args.head_ref).to eq(new_branch_commit_id)
        expect(args.paths).to eq([])
      end
    end

    it 'accepts both head and diff point as the first two arguments' do
      args.from_argv(['master', new_branch], repo).tap do |args|
        expect(args.diff_point_ref).to eq(master_commit_id)
        expect(args.head_ref).to eq(new_branch)
        expect(args.paths).to eq([])
      end
    end

    it 'allows the second argument to be a path' do
      args.from_argv(['master', '.'], repo).tap do |args|
        expect(args.diff_point_ref).to eq(master_commit_id)
        expect(args.head_ref).to eq(new_branch_commit_id)
        expect(args.paths).to eq(['.'])
      end
    end

    it 'allows multiple paths' do
      args.from_argv(['master', 'file.txt', 'file2.txt'], repo).tap do |args|
        expect(args.diff_point_ref).to eq(master_commit_id)
        expect(args.head_ref).to eq(new_branch_commit_id)
        expect(args.paths).to eq(['file.txt', 'file2.txt'])
      end
    end

    it 'allows paths to be separated by --' do
      args.from_argv(['master', '--', 'file.txt', 'file2.txt'], repo).tap do |args|
        expect(args.diff_point_ref).to eq(master_commit_id)
        expect(args.head_ref).to eq(new_branch_commit_id)
        expect(args.paths).to eq(['file.txt', 'file2.txt'])
      end
    end

    it 'allows a head and diff point followed by -- and paths' do
      args.from_argv(['master', new_branch, '--', 'file.txt', 'file2.txt'], repo).tap do |args|
        expect(args.diff_point_ref).to eq(master_commit_id)
        expect(args.head_ref).to eq(new_branch)
        expect(args.paths).to eq(['file.txt', 'file2.txt'])
      end
    end
  end

  describe DiffCommand do
    let(:api) { double }
    let(:command) { DiffCommand.new(api, terminal, repo, [master_commit_id, new_branch_commit_id]) }
    let(:terminal) { FakeTerminal.new }

    describe '#execute' do
      it 'makes a diff api call' do
        expect(api).to receive(:diff)
          .with(
            repo_name: repo_name,
            head_ref: new_branch_commit_id,
            diff_point_ref: master_commit_id,
            paths: ''
          )
          .and_return(Response.new({}))

        command.execute
      end

      it 'prints the number of phrases added, removed, and modified' do
        expect(api).to receive(:diff)
          .with(
            repo_name: repo_name,
            head_ref: new_branch_commit_id,
            diff_point_ref: master_commit_id,
            paths: ''
          )
          .and_return(
            Response.new(
              sample_diff(new_branch_commit_id)
            )
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
        expect(api).to receive(:diff)
          .with(
            repo_name: repo_name,
            head_ref: new_branch_commit_id,
            diff_point_ref: master_commit_id,
            paths: ''
          )
          .and_return(
            Response.new({ 'error' => 'Jelly beans' }.merge(
              sample_diff(new_branch_commit_id))
            )
          )

        command.execute

        expect(terminal).to have_said('Jelly beans')
        expect(terminal).to_not have_said("+ I'm a little teapot (about.training.teapot)", :green)
      end
    end
  end
end
