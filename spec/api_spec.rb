# encoding: UTF-8

require 'spec_helper'

include Rosette::Client

describe Api do
  let(:api_class) { Api }

  it 'uses default options' do
    api_class.new.tap do |api|
      expect(api.host).to eq('localhost')
      expect(api.port).to eq(8080)
      expect(api.version).to eq('v1')
    end
  end

  it 'uses only some default options' do
    api_class.new(host: 'foo.com').tap do |api|
      expect(api.host).to eq('foo.com')
      expect(api.port).to eq(8080)
      expect(api.version).to eq('v1')
    end
  end

  shared_examples 'an api endpoint' do
    let(:api) { api_class.new }
    let(:params) { { param: 'value' } }
    let(:endpoint) { method }

    before(:each) do
      url = "http://localhost:8080/v1/#{path}"

      args = case verb
        when :get
          ["#{url}/#{endpoint_override rescue endpoint}.json/?param=value"]
        else
          ["#{url}/#{endpoint_override rescue endpoint}.json", params]
      end

      allow(api).to receive(verb).with(*args).and_return('{"foo":"bar"}')
    end

    it 'wraps the response in a Response object' do
      expect(api.send(endpoint, params)).to be_a(Response)
    end
  end

  context 'get requests' do
    let(:verb) { :get }

    describe '#diff' do
      let(:path) { 'git' }
      let(:method) { :diff }
      it_behaves_like 'an api endpoint'
    end

    describe '#show' do
      let(:path) { 'git' }
      let(:method) { :show }
      it_behaves_like 'an api endpoint'
    end

    describe '#status' do
      let(:path) { 'git' }
      let(:method) { :status }
      it_behaves_like 'an api endpoint'
    end

    describe '#commit' do
      let(:path) { 'git' }
      let(:method) { :commit }
      it_behaves_like 'an api endpoint'
    end

    describe '#snapshot' do
      let(:path) { 'git' }
      let(:method) { :snapshot }
      it_behaves_like 'an api endpoint'
    end

    describe '#repo_snapshot' do
      let(:path) { 'git' }
      let(:method) { :repo_snapshot }
      it_behaves_like 'an api endpoint'
    end

    describe '#add_or_update_translation' do
      let(:path) { 'translations' }
      let(:method) { :add_or_update_translation }
      let(:endpoint_override) { 'add_or_update' }
      it_behaves_like 'an api endpoint'
    end
  end
end
