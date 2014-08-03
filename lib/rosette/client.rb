# encoding: UTF-8

require 'rosette/client/cli'
require 'rosette/client/repo'

module Rosette
  module Client
    autoload :Api,         'rosette/client/api'
    autoload :Terminal,    'rosette/client/terminal'
    autoload :Commands,     'rosette/client/commands'
  end
end
