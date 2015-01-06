$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rosette/client/version'

Gem::Specification.new do |s|
  s.name     = "rosette-client"
  s.version  = ::Rosette::Client::VERSION
  s.authors  = ["Cameron Dutro"]
  s.email    = ["camertron@gmail.com"]
  s.homepage = "http://github.com/camertron"

  s.description = s.summary = "Git command integration for the Rosette internationalization platform that manages the translatable content in the source files of a git repository."

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.add_dependency 'colorize', '~> 0.7.0'
  s.add_dependency 'json', '~> 1.8.0'

  s.executables << 'git-rosette'

  s.require_path = 'lib'
  s.files = Dir["{lib,spec}/**/*", "Gemfile", "History.txt", "README.md", "Rakefile", "rosette-client.gemspec"]
end
