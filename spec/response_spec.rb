# encoding: UTF-8

require 'spec_helper'

include Rosette::Client

describe Response do
  let(:response_class) { Response }

  it 'responds to methods that are also keys in the attributes hash' do
    response = response_class.new({ 'hello' => 'world' })
    expect(response.hello).to eq('world')
  end

  it "returns nil if the method isn't part of the attributes hash" do
    response = response_class.new({ 'hello' => 'world' })
    expect(response.nothing).to be_nil
  end

  describe 'from_api_response' do
    it 'accepts a hash of attributes and returns an instance of Response' do
      response = response_class.from_api_response({ 'foo' => 'bar' })
      expect(response).to be_a(response_class)
      expect(response.attributes).to eq({ 'foo' => 'bar' })
    end
  end

  describe '#error?' do
    it 'returns true if the attributes hash contains an "error" key' do
      response = response_class.new({ 'error' => 'jelly beans' })
      expect(response).to be_error
    end

    it 'returns false if the attributes hasn does not contain an "error" key' do
      response = response_class.new({ 'not error' => 'lima beans' })
      expect(response).to_not be_error
    end
  end

  describe '#success?' do
    it 'returns true if the attributes hasn does not contain an "error" key' do
      response = response_class.new({ 'not error' => 'lima beans' })
      expect(response).to be_success
    end

    it 'returns false if the attributes hash contains an "error" key' do
      response = response_class.new({ 'error' => 'jelly beans' })
      expect(response).to_not be_success
    end
  end
end
