# encoding: UTF-8

class FakeWriter
  attr_reader :streams

  def initialize
    @streams = {}
  end

  def open(file, mode)
    streams[file] ||= StringIO.new
    yield streams[file]
  end

  def contents_of(file)
    streams[file].string
  end

  def has_written_content_for?(file)
    streams.include?(file)
  end
end
