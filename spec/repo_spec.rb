# encoding: UTF-8

require 'spec_helper'

include Rosette::Client

describe Repo do
  let(:base_repo) { TmpRepo.new }
  let(:repo) { Repo.new(base_repo.working_dir) }

  before(:each) do
    add_user_to(base_repo)
    base_repo.create_file('file.txt') { |f| f.write('hello, world') }
    base_repo.add_all
    base_repo.commit('Initial commit')
  end

  describe '#get_head' do
    it 'returns the symbolic ref (i.e. branch name) of HEAD' do
      expect(repo.get_head).to eq('master')
    end
  end

  describe '#rev_parse' do
    it 'returns the commit id of the given ref' do
      expect(repo.rev_parse('master')).to(
        eq(base_repo.git('rev-parse master').strip)
      )
    end
  end
end
