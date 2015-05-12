# encoding: UTF-8

require 'spec_helper'
require 'base64'

include Rosette::Client
include Rosette::Client::Commands

describe PullCommand do
  let(:api) { double }
  let(:base_repo) { TmpRepo.new }
  let(:repo) { Repo.new(base_repo.working_dir) }
  let(:terminal) { FakeTerminal.new }
  let(:writer) { FakeWriter.new }
  let(:repo_name) { 'my_awesome_repo' }
  let(:commit_id) { base_repo.git('rev-parse HEAD').strip }
  let(:serializer) { 'yaml/rails' }
  let(:file_pattern) { 'config/locales/%{locale.code}.yml' }
  let(:paths) { '' }
  let(:command) do
    PullCommand.new(
      api, terminal, writer, repo, [
        commit_id, "-f #{file_pattern}", "-s #{serializer}"
      ]
    )
  end

  let(:locales) do
    [
      {
        'code' => 'ja-JP',
        'language' => 'ja',
        'territory' => 'JP'
      }, {
        'code' => 'pt-BR',
        'language' => 'pt',
        'territory' => 'BR'
      }
    ]
  end

  let(:params) do
    {
      repo_name: repo_name,
      ref: commit_id,
      serializer: serializer,
      base_64_encode: true,
      paths: paths
    }
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

  context 'with a mocked list of locales' do
    before(:each) do
      expect(api).to receive(:locales)
        .with(repo_name: repo_name)
        .and_return(Response.from_api_response(locales))

      locales.each do |locale|
        expect(api).to receive(:export)
          .with(params.merge(locale: locale['code']))
          .and_return(
            Response.from_api_response({
              'payload' => Base64.encode64("payload for #{locale['code']}")
            })
          )
      end
    end

    describe '#execute' do
      it 'exports translations for each locale' do
        command.execute

        locales.each do |locale|
          file = file_pattern % { :'locale.code' => locale['code'] }
          expect(writer).to have_written_content_for(file)
          expect(writer.contents_of(file)).to eq("payload for #{locale['code']}")
        end
      end

      context 'with a territory-based file pattern' do
        let(:file_pattern) { 'config/locales/%{locale.territory}.yml' }

        it 'exports translations for each locale' do
          command.execute

          locales.each do |locale|
            file = file_pattern % { :'locale.territory' => locale['territory'] }
            expect(writer).to have_written_content_for(file)
            expect(writer.contents_of(file)).to eq("payload for #{locale['code']}")
          end
        end
      end

      context 'with a language-based file pattern' do
        let(:file_pattern) { 'config/locales/%{locale.language}.yml' }

        it 'exports translations for each locale' do
          command.execute

          locales.each do |locale|
            file = file_pattern % { :'locale.language' => locale['language'] }
            expect(writer).to have_written_content_for(file)
            expect(writer.contents_of(file)).to eq("payload for #{locale['code']}")
          end
        end
      end
    end
  end
end
