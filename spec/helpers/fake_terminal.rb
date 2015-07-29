# encoding: UTF-8

class FakeTerminal
  attr_reader :statements

  def initialize
    @statements = []
  end

  def say(text, color = nil)
    statements << [text, color]
  end

  def all_statements
    @statements.map(&:first)
  end

  def has_said?(text_or_regex, color = nil)
    case text_or_regex
      when Regexp
        statements.any? do |statement|
          matches = text_or_regex =~ statement.first
          matches &&= color == statement.last if color
          matches
        end
      when String
        statements.any? do |statement|
          matches = text_or_regex == statement.first
          matches &&= color == statement.last if color
          matches
        end
    end
  end
end
