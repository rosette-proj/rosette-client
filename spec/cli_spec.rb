# encoding: UTF-8

require 'spec_helper'

include Rosette::Client

describe Cli do
  let(:api) { double }
  let(:base_repo) { TmpRepo.new }
  let(:repo) { Repo.new(base_repo.working_dir) }
  let(:terminal) { FakeTerminal.new }
  let(:writer) { FakeWriter.new }
  let(:cli) { Cli.new(terminal, writer, api, repo) }

  before(:each) do
    add_user_to(base_repo)
  end

  describe '#start' do
    it 'resolves the command into a class and executes it' do
      base_repo.create_file('file.txt') { |f| f.write('hello, world') }
      base_repo.add_all
      base_repo.commit('Initial commit')

      expect(api).to receive(:commit).and_return(Response.from_api_response({ 'foo' => 'bar' }))
      cli.start(['commit', base_repo.git('rev-parse HEAD').strip])
    end

    it "prints a message if the command isn't recognized" do
      cli.start(['foobar'])
      expect(terminal).to have_said("Command 'foobar' not recognized.")
    end
  end
end
