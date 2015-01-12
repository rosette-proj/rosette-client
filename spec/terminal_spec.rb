# encoding: UTF-8

require 'spec_helper'

include Rosette::Client

describe Terminal do
  let(:stream) { StringIO.new }
  let(:terminal) { Terminal.new(stream) }

  describe '#say' do
    it 'writes to the stream' do
      terminal.say("I'm a little teapot")
      expect(stream.string).to eq("I'm a little teapot\n")
    end

    it 'colorizes the output when asked' do
      terminal.say("I'm a little teapot", :red)
      expect(stream.string).to eq("\e[0;31;49mI'm a little teapot\e[0m\n")
    end
  end
end
